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

- (id)runJSONString:(NSString *)JSONString
{
    NSData *data       = [NSData dataWithBytes:[JSONString UTF8String] length:JSONString.length];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:nil];
    assert(dict);
    
    return [self runJSON:dict];
}

- (NSDictionary *)blankObject {
    return @{
        @"id":        [NSUUID UUID],
        @"properties": @[],
        @"code":      @[]
    };
}

- (id)runJSON:(NSDictionary *)JSON {
    NSDictionary *obj = [self blankObject];
    [self loadObject:obj];
    ZSExecutionContext *context = [ZSExecutionContext contextWithObjectId:obj[@"id"]
                                                              environment:_properties[obj[@"id"]]];
    return [self runJSON:JSON context:context];
}

- (id)runJSON:(NSDictionary *)JSON context:(ZSExecutionContext *)context {
    return [self runCode:JSON context:context];
}

- (id)runSuite:(NSArray *)suite {
    NSDictionary *obj = [self blankObject];
    [self loadObject:obj];
    ZSExecutionContext *context = [ZSExecutionContext contextWithObjectId:obj[@"id"]
                                                              environment:_properties[obj[@"id"]]];
    return [self runSuite:suite context:context];
}

- (id)runSuite:(NSArray *)suite context:(ZSExecutionContext *)context {
    __block id returnValue = nil;
    
    [suite each:^(id obj) {
        returnValue = [self runCode:obj context:context];
    }];
    
    return returnValue;
}

- (id)runCode:(id)code context:(ZSExecutionContext *)context {
    NSString *key = [code allKeys][0];
    id data = code[key];
    
    if ([key isEqualToString:@"program"] || [key isEqualToString:@"code"]) {
        return [self runSuite:data context:context];
    }
    
    else if ([key isEqualToString:@"set"]) {
        id newValue = [self evaluateExpression:data[1] context:context];
        
        NSString *identifier = context.environment[data[0]];
        // If the identifier already exists, we want to update the one
        // already in the data store so that nested scopes update their
        // outer-scopes
        if (identifier)
            _dataStore[identifier] = newValue;
        else
            context.environment[data[0]] = [self IDForStoringValue:newValue];
        
        if (_delegate) {
            [_delegate interpreter:self
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
    
    else if ([key isEqualToString:@"scope"]) {
        return [self runSuite:data context:[context contextWithNewEnvironment]];
    }
    
    else if ([key isEqualToString:@"on_event"]) {
        [_events[context.objectID] setObject:@{ @"code": data[@"code"], @"context": context } forKey:data[@"name"]];
    }

    else {
        return [self evaluateExpression:code context:context];
    }

    return nil;
}

- (NSString *)IDForStoringValue:(id)value {
    NSString *UUID = [NSUUID UUID];
    _dataStore[UUID] = value;
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

    if ([key isEqualToString:@"call"]) {
        // It's legal to not specify an parameters array
        NSArray *params = (code[@"parameters"] ? code[@"parameters"] : @[]);
        params = [params map:^id(id obj) {
            return [self evaluateExpression:obj context:context];
        }];

        if (code[@"async"] && [code[@"async"] boolValue]) {
            id (^method)(NSString *, NSArray *, void(^)(id)) = _methods[code[@"method"]];

            __block id returnValue = nil;
            method(context.objectID, params, ^void(id obj){
                returnValue = obj;
            });

            while (!returnValue) {
                [NSThread sleepForTimeInterval:0.01];
            }
            
            return returnValue;
        } else {
            id (^method)(NSString *, NSArray *) = _methods[code[@"method"]];
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
        NSString *identifier = context.environment[code];
        if (!identifier)
            NSLog(@"ZSInterpreter#evaluateExpression:context: - Attempt to access unknown variable: %@", code);
        return _dataStore[identifier];
    }
    
    else {
        NSAssert(false, ([NSString stringWithFormat:@"Error: attempted to run unknown code key: %@", key]));
    }
    
    return nil;
}

- (id)evaluateMathExpression:(id)expression context:(ZSExecutionContext *)context {
    NSString *key = [expression allKeys][0];
    id code = expression[key];
    
    if ([key isEqualToString:@"+"]) {
        CGFloat first = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat second = [[self evaluateExpression:code[1] context:context] floatValue];
        
        return @(first + second);
    }
    
    else if ([key isEqualToString:@"-"]) {
        CGFloat first = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat second = [[self evaluateExpression:code[1] context:context] floatValue];
        
        return @(first - second);
    }
    
    else if ([key isEqualToString:@"*"]) {
        CGFloat first = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat second = [[self evaluateExpression:code[1] context:context] floatValue];
        
        return @(first * second);
    }
    
    else if ([key isEqualToString:@"/"]) {
        CGFloat first = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat second = [[self evaluateExpression:code[1] context:context] floatValue];
        
        return @(first / second);
    }
    
    else {
        return nil;
    }
}

- (id)evaluateBooleanExpression:(id)expression context:(ZSExecutionContext *)context {
    NSString *key = [expression allKeys][0];
    id code = expression[key];
    
    if ([key isEqualToString:@"=="]) {
        id firstExpression = [self evaluateExpression:code[0] context:context];
        id secondExpression = [self evaluateExpression:code[1] context:context];
        
        if ([firstExpression isEqual:secondExpression])
            return @YES;
        else
            return @NO;
    }
    
    else if ([key isEqualToString:@"<"]) {
        CGFloat firstExpression = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat secondExpression = [[self evaluateExpression:code[1] context:context] floatValue];
        
        if (firstExpression < secondExpression)
            return @YES;
        else
            return @NO;
    }
    
    else if ([key isEqualToString:@">"]) {
        CGFloat firstExpression = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat secondExpression = [[self evaluateExpression:code[1] context:context] floatValue];
        
        if (firstExpression > secondExpression)
            return @YES;
        else
            return @NO;
    }
    
    else if ([key isEqualToString:@"<="]) {
        CGFloat firstExpression = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat secondExpression = [[self evaluateExpression:code[1] context:context] floatValue];
        
        if (firstExpression <= secondExpression)
            return @YES;
        else
            return @NO;
    }
    
    else if ([key isEqualToString:@">="]) {
        CGFloat firstExpression = [[self evaluateExpression:code[0] context:context] floatValue];
        CGFloat secondExpression = [[self evaluateExpression:code[1] context:context] floatValue];
        
        if (firstExpression >= secondExpression)
            return @YES;
        else
            return @NO;
    }
    
    else {
        return nil;
    }
}

- (void)loadMethod:(NSDictionary *)method {
    [_methods setObject:method[@"block"] forKey:method[@"method"]];
}

- (void)loadTrait:(NSDictionary *)trait {
    [_methods setObject:trait forKey:trait[@"id"]];
}

- (void)loadObject:(NSDictionary *)obj {
    [_events setObject:[NSMutableDictionary dictionary] forKey:obj[@"id"]];
    [_properties setObject:[self dictionaryForStoringDictionary:obj[@"properties"]] forKey:obj[@"id"]];
    [_objects setObject:obj forKey:obj[@"id"]];
    ZSExecutionContext *context = [ZSExecutionContext contextWithObjectId:obj[@"id"]
                                                              environment:_properties[obj[@"id"]]];
    [self runSuite:obj[@"code"] context:context];
}

- (void)triggerEvent:(NSString *)event {
    [_objects each:^(id key, id obj) {
        [self triggerEvent:event onObjectWithIdentifier:key parameters:@{}];
    }];
}

- (void)triggerEvent:(NSString *)event onObjectWithIdentifier:(NSString *)objectID {
    [self triggerEvent:event onObjectWithIdentifier:objectID parameters:@{}];
}

- (void)triggerEvent:(NSString *)event
          parameters:(NSDictionary *)parameters {
    
}

- (void)  triggerEvent:(NSString *)event
onObjectWithIdentifier:(NSString *)objectID
            parameters:(NSDictionary *)parameters {
    NSMutableDictionary *environment = [[_events[objectID][event][@"context"] environment] mutableCopy];
    [environment addEntriesFromDictionary:[self dictionaryForStoringDictionary:parameters]];
    ZSExecutionContext *newContext = [ZSExecutionContext contextWithObjectId:objectID
                                                                 environment:environment];
    [self runSuite:_events[objectID][event][@"code"] context:newContext];
}

- (void)removeObjectWithIdentifier:(NSString *)identifier {
    [_objects removeObjectForKey:identifier];
    [_events removeObjectForKey:identifier];
    [_properties removeObjectForKey:identifier];
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
- (NSDictionary *)objects {
    return [_objects map:^id(id key, id obj) {
        return obj[@"properties"];
    }];
}
@end
