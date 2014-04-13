//
//  ZSInterpreter.m
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import "ZSInterpreter.h"
#import "ZSExecutionContext.h"
#import "BlocksKit.h"
#import "NSString+Zuse.h"
#import "NSNumber+Zuse.h"

@interface ZSInterpreter ()

@property (strong, nonatomic) NSMutableDictionary *methods;
@property (strong, nonatomic) NSMutableDictionary *events;
@property (strong, nonatomic) NSMutableDictionary *properties;
@property (strong, nonatomic) NSMutableDictionary *objects;
@property (strong, nonatomic) NSMutableDictionary *dataStore;

@end

@implementation ZSInterpreter

+ (instancetype)interpreter {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _methods    = [@{} mutableCopy];
        _events     = [@{} mutableCopy];
        _objects    = [@{} mutableCopy];
        _properties = [@{} mutableCopy];
        _dataStore  = [@{} mutableCopy];
    }
    
    return self;
}

- (NSDictionary *)blankObject {
    return @{
        @"id":        [[NSUUID UUID] UUIDString],
        @"properties": @{},
        @"code":      @[]
    };
}

- (id)runJSON:(NSDictionary *)JSON {
    NSDictionary *obj = [self blankObject];
    [self loadObject:obj];
    ZSExecutionContext *context = [ZSExecutionContext contextWithObjectId:obj[@"id"]
                                                              environment:self.properties[obj[@"id"]]];
    return [self runJSON:JSON context:context];
}

- (id)runJSON:(NSDictionary *)JSON context:(ZSExecutionContext *)context {
    return [self runCode:JSON context:context];
}

- (id)runSuite:(NSArray *)suite {
    NSDictionary *obj = [self blankObject];
    [self loadObject:obj];
    ZSExecutionContext *context = [ZSExecutionContext contextWithObjectId:obj[@"id"]
                                                              environment:self.properties[obj[@"id"]]];
    return [self runSuite:suite context:context];
}

- (id)runSuite:(NSArray *)suite context:(ZSExecutionContext *)context {
    __block id returnValue = nil;
    
    [suite each:^(NSDictionary *obj) {
        returnValue = [self runCode:obj context:context];
    }];
    
    return returnValue;
}

- (id)runCode:(NSDictionary *)code context:(ZSExecutionContext *)context {
    NSString *key = [code allKeys][0];
    id data = code[key];
    
    if ([key isEqualToString:@"suite"]) {
        return [self runSuite:data context:[context contextWithNewEnvironment]];
    }
    
    else if ([key isEqualToString:@"set"]) {
        id newValue = [self evaluateExpression:data[1] context:context];
        
        NSString *identifier = context.environment[data[0]];
        // If the identifier already exists, we want to update the one
        // already in the data store so that nested scopes update their
        // outer-scopes
        if (identifier)
            self.dataStore[identifier] = newValue;
        else
            context.environment[data[0]] = [self IDForStoringValue:newValue];
        
        if (self.delegate) {
            [self.delegate interpreter:self
                  objectWithIdentifier:context.objectID
                   didUpdateProperties:@{ data[0]: newValue }];
        }
    }
    
    else if ([key isEqualToString:@"if"]) {
        if ([[self evaluateExpression:data[@"test"] context:context] boolValue]) {
            return [self runSuite:data[@"true"] context:context];
        } else {
            return [self runSuite:data[@"false"] context:context];
        }
    }
    
    else if ([key isEqualToString:@"on_event"]) {
        NSMutableArray *events = self.events[context.objectID][data[@"name"]];
        if (!events) {
            events = [NSMutableArray array];
            self.events[context.objectID][data[@"name"]] = events;
        }
        
        [events addObject:@{ @"code": data[@"code"], @"context": context }];
    }
    
    else if ([key isEqualToString:@"trigger_event"]) {
        [self triggerEvent:data[@"name"] parameters:data[@"parameters"]];
    }

    else {
        return [self evaluateExpression:code context:context];
    }

    return nil;
}

- (NSString *)IDForStoringValue:(id)value {
    NSString *UUID = [[NSUUID UUID] UUIDString];
    self.dataStore[UUID] = value;
    return UUID;
}

- (NSMutableDictionary *)dictionaryForStoringDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *dict = [[dictionary map:^id(id key, id obj) {
        return [self IDForStoringValue:obj];
    }] mutableCopy];
    return dict;
}

- (id)evaluateExpression:(id)expression context:(ZSExecutionContext *)context {
    // Atoms should just return themselves
    if ([expression isKindOfClass:[NSNumber class]] || [expression isKindOfClass:[NSString class]]) {
        return expression;
    }

    NSString *key = [expression allKeys][0];
    id code = expression[key];
    
    if ([key isEqualToString:@"object"]) {
        [self loadObject:code];
        return code;
    }
    
    else if ([key isEqualToString:@"call"]) {
        // It's legal to not specify a parameters array
        NSArray *params = code[@"parameters"] ?: @[];
        params = [params map:^id(id obj) {
            return [self evaluateExpression:obj context:context];
        }];

        if (code[@"async"] && [code[@"async"] boolValue]) {
            void (^method)(NSString *, NSArray *, void(^)(id)) = self.methods[code[@"method"]];

            __block id returnValue = nil;
            method(context.objectID, params, ^void(id obj){
                returnValue = obj;
            });

            while (!returnValue) {
                [NSThread sleepForTimeInterval:0.01];
            }
            
            return returnValue;
        } else {
            id (^method)(NSString *, NSArray *) = self.methods[code[@"method"]];
            return method(context.objectID, params);
        }
    }
    
    id returnValue = nil;
    
    if ((returnValue = [self evaluateMathExpression:expression context:context])) {
        return returnValue;
    }
    
    else if ((returnValue = [self evaluateBooleanExpression:expression context:context])) {
        return returnValue;
    }

    else if ([key isEqualToString:@"get"]) {
        if ([self.delegate interpreter:self shouldDelegateProperty:code objectIdentifier:context.objectID]) {
            return [self.delegate interpreter:self valueForProperty:code objectIdentifier:context.objectID];
        } else {
            NSString *identifier = context.environment[code];
            if (!identifier)
                NSLog(@"ZSInterpreter#evaluateExpression:context: - Attempt to access unknown variable: %@", code);
            return self.dataStore[identifier];
        }
    }
    
    else {
        NSAssert(false, ([NSString stringWithFormat:@"Error: attempted to run unknown code key: %@", key]));
    }
    
    return nil;
}

- (id)evaluateMathExpression:(id)expression context:(ZSExecutionContext *)context {
    NSString *key = [expression allKeys][0];
    id code = expression[key];
    
    static NSDictionary *values = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        values = @{
            @"+": ^id(CGFloat first, CGFloat second) { return @(first + second); },
            @"-": ^id(CGFloat first, CGFloat second) { return @(first - second); },
            @"*": ^id(CGFloat first, CGFloat second) { return @(first * second); },
            @"/": ^id(CGFloat first, CGFloat second) { return @(first / (second ?: 1)); },
            @"%": ^id(CGFloat first, CGFloat second) { return @((NSInteger)first % (NSInteger)second); }
        };
    });
    
    id(^function)(CGFloat, CGFloat) = values[key];
    
    if (function) {
        CGFloat first =  [[[self evaluateExpression:code[0] context:context] coercedNumber] floatValue];
        CGFloat second = [[[self evaluateExpression:code[1] context:context] coercedNumber] floatValue];
        return function(first, second);
    }
    
    return nil;
}

- (id)evaluateBooleanExpression:(id)expression context:(ZSExecutionContext *)context {
    NSString *key = [expression allKeys][0];
    id code = expression[key];
    
    
    static NSDictionary *equalityValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        equalityValues = @{
            @"==": ^id(id first, id second) { return @([first isEqual:second]); },
            @"!=": ^id(id first, id second) { return @(![first isEqual:second]); }
        };
    });
    
    id(^equalityFunction)(id, id) = equalityValues[key];
    
    if (equalityFunction) {
        id first  = [self evaluateExpression:code[0] context:context];
        id second = [self evaluateExpression:code[1] context:context];
        return equalityFunction(first, second);
    }
    
    static NSDictionary *comparisonValues = nil;
    static dispatch_once_t comparisonOnceToken;
    dispatch_once(&comparisonOnceToken, ^{
        comparisonValues = @{
            @"<":  ^id(CGFloat first, CGFloat second) { return @(first <  second); },
            @">":  ^id(CGFloat first, CGFloat second) { return @(first >  second); },
            @"<=": ^id(CGFloat first, CGFloat second) { return @(first <= second); },
            @">=": ^id(CGFloat first, CGFloat second) { return @(first >= second); },
        };
    });
    
    
    id(^comparisonFunction)(CGFloat, CGFloat) = comparisonValues[key];
    
    if (comparisonFunction) {
        CGFloat first  = [[[self evaluateExpression:code[0] context:context] coercedNumber] floatValue];
        CGFloat second = [[[self evaluateExpression:code[1] context:context] coercedNumber] floatValue];
        return comparisonFunction(first, second);
    }
    
    return nil;
}

- (void)loadMethod:(NSDictionary *)method {
    [self.methods setObject:method[@"block"] forKey:method[@"method"]];
}

- (void)loadObject:(NSDictionary *)obj {
    [self.events setObject:[NSMutableDictionary dictionary] forKey:obj[@"id"]];
    [self.properties setObject:[self dictionaryForStoringDictionary:obj[@"properties"]] forKey:obj[@"id"]];
    [self.objects setObject:obj forKey:obj[@"id"]];
    ZSExecutionContext *context = [ZSExecutionContext contextWithObjectId:obj[@"id"]
                                                              environment:self.properties[obj[@"id"]]];
    [self runSuite:obj[@"code"] context:context];
}

- (void)triggerEvent:(NSString *)event {
    [self triggerEvent:event parameters:@{}];
}

- (void)triggerEvent:(NSString *)event onObjectWithIdentifier:(NSString *)objectID {
    [self triggerEvent:event onObjectWithIdentifier:objectID parameters:@{}];
}

- (void)triggerEvent:(NSString *)event
          parameters:(NSDictionary *)parameters {
    NSArray *objectIdentifiers = self.objects.allKeys;
    [objectIdentifiers each:^(NSString *identifier) {
        [self triggerEvent:event onObjectWithIdentifier:identifier parameters:parameters];
    }];
}

- (void)  triggerEvent:(NSString *)event
onObjectWithIdentifier:(NSString *)objectID
            parameters:(NSDictionary *)parameters {
    [self.events[objectID][event] each:^(NSDictionary *event) {
        NSMutableDictionary *environment = [[event[@"context"] environment] mutableCopy];
        [environment addEntriesFromDictionary:[self dictionaryForStoringDictionary:parameters]];
        ZSExecutionContext *newContext = [ZSExecutionContext contextWithObjectId:objectID
                                                                     environment:environment];
        [self runSuite:event[@"code"] context:newContext];
    }];
}

- (void)removeObjectWithIdentifier:(NSString *)identifier {
    [self.objects removeObjectForKey:identifier];
    [self.events removeObjectForKey:identifier];
    [self.properties removeObjectForKey:identifier];
}

/*
 {
   "paddle1": {
     "x": 1,
     "y": 2",
     "width": 10,
     "height": 100
   }
 }
*/
- (NSDictionary *)allObjects {
    return [self.objects map:^id(id key, id obj) {
        return obj[@"properties"];
    }];
}
@end
