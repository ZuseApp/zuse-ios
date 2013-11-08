//
//  INInterpreter.m
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import "INInterpreter.h"
#import <BlocksKit/BlocksKit.h>

@interface INInterpreter ()

@property (strong, nonatomic) NSDictionary *program;
@property (strong, nonatomic) NSMutableDictionary *methods;
@property (strong, nonatomic) NSMutableDictionary *events;
@property (strong, nonatomic) NSMutableDictionary *properties;
@property (strong, nonatomic) NSMutableDictionary *objects;

@end

@implementation INInterpreter

+ (instancetype)interpreter
{
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _methods    = [@{} mutableCopy];
        _events     = [@{} mutableCopy];
        _objects    = [@{} mutableCopy];
        _properties = [@{} mutableCopy];
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
        @"variables": @[],
        @"code":      @[]
    };
}

- (id)runJSON:(NSDictionary *)JSON {
    NSDictionary *obj = [self blankObject];
    [self loadObject:obj];
    return [self runJSON:JSON objectIdentifier:obj[@"id"]];
}

- (id)runJSON:(NSDictionary *)JSON objectIdentifier:(NSString *)objectID {
    return [self runCode:JSON objectIdentifier:objectID];
}

- (id)runSuite:(NSArray *)suite {
    NSDictionary *obj = [self blankObject];
    [self loadObject:obj];
    return [self runSuite:suite objectIdentifier:obj[@"id"]];
}

- (id)runSuite:(NSArray *)suite objectIdentifier:(NSString *)objectID {
    __block id returnValue = nil;
    
    [suite enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        returnValue = [self runCode:obj objectIdentifier:objectID];
    }];
    
    return returnValue;
}

- (id)runCode:(id)code objectIdentifier:(NSString *)objectID {
    NSString *key = [code allKeys][0];
    id data = code[key];
    
    if ([key isEqualToString:@"program"] || [key isEqualToString:@"suite"]) {
        return [self runSuite:data objectIdentifier:objectID];
    }
    
    else if ([key isEqualToString:@"set"]) {
        NSMutableDictionary *properties = _properties[objectID];
        properties[data[0]] = [self evaluateExpression:data[1] objectIdentifier:objectID];
    }
    
    else if ([key isEqualToString:@"if"]) {
        if ([[self evaluateExpression:data[@"test"] objectIdentifier:objectID] boolValue]) {
            return [self runSuite:data[@"true"] objectIdentifier:objectID];
        } else {
            return [self runSuite:data[@"false"] objectIdentifier:objectID];
        }
    }
    
    else if ([key isEqualToString:@"on_event"]) {
        [_events[objectID] setObject:data[@"suite"] forKey:data[@"name"]];
    }

    else {
        return [self evaluateExpression:code objectIdentifier:objectID];
    }

    return nil;
}

- (id)evaluateExpression:(id)expression objectIdentifier:(NSString *)objectID {
    // Atoms should just return themselves
    if ([expression isKindOfClass:[NSNumber class]] || [expression isKindOfClass:[NSString class]]) {
        return expression;
    }

    NSString *key = [expression allKeys][0];
    id code = expression[key];

    if ([key isEqualToString:@"call"]) {
        // It's legal to not specify an args array
        NSArray *args = (code[@"args"] ? code[@"args"] : @[]);
        args = [args map:^id(id obj) {
            return [self evaluateExpression:obj objectIdentifier:objectID];
        }];

        if (code[@"async"] && [code[@"async"] boolValue]) {
            id (^method)(NSArray *, void(^)(id)) = _methods[code[@"method"]];

            __block id returnValue = nil;
            method(args, ^void(id obj){
                returnValue = obj;
            });

            while (!returnValue) {
                [NSThread sleepForTimeInterval:0.01];
            }
            
            return returnValue;
        } else {
            id (^method)(NSArray *) = _methods[code[@"method"]];
            return method(args);
        }
    }

    else if ([key isEqualToString:@"+"]) {
        NSInteger first = [[self evaluateExpression:code[0] objectIdentifier:objectID] integerValue];
        NSInteger second = [[self evaluateExpression:code[1] objectIdentifier:objectID] integerValue];
        
        return @(first + second);
    }
    
    else if ([key isEqualToString:@"=="]) {
        id firstExpression = [self evaluateExpression:code[0] objectIdentifier:objectID];
        id secondExpression = [self evaluateExpression:code[1] objectIdentifier:objectID];
        
        if ([firstExpression isEqual:secondExpression])
            return @YES;
        else
            return @NO;
    }
    
    else if ([key isEqualToString:@"get"]) {
        NSMutableDictionary *properties = _properties[objectID];
        return properties[code];
    }
    
    else {
        NSAssert(false, ([NSString stringWithFormat:@"Error: attempted to run unknown code key: %@", key]));
    }
    
    return nil;
}

- (void)loadMethod:(NSDictionary *)method {
    [_methods setObject:method[@"block"] forKey:method[@"name"]];
}

- (void)loadObject:(NSDictionary *)obj {
    [_events setObject:[NSMutableDictionary dictionary] forKey:obj[@"id"]];
    [_properties setObject:[obj[@"variables"] mutableCopy] forKey:obj[@"id"]];
    [_objects setObject:obj forKey:obj[@"id"]];
    [self runSuite:obj[@"code"] objectIdentifier:obj[@"id"]];
}

- (void)triggerEvent:(NSString *)event {
    [_objects each:^(id key, id obj) {
        [self triggerEvent:event onObjectWithIdentifier:key];
    }];
}

- (void)triggerEvent:(NSString *)event onObjectWithIdentifier:(NSString *)objectID {
    [self runSuite:_events[objectID][event] objectIdentifier:objectID];
}

@end
