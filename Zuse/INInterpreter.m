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
        _methods = [@{} mutableCopy];
        _events  = [@{} mutableCopy];
        _objects = [@{} mutableCopy];
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

- (void)run {
    [_objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self runSuite:obj[@"code"] properties:[obj[@"variables"] mutableCopy]];
    }];
}

- (id)runJSON:(NSDictionary *)JSON {
    return [self runJSON:JSON properties:[@{} mutableCopy]];
}

- (id)runJSON:(NSDictionary *)JSON properties:(NSMutableDictionary *)properties {
    NSString *key = [JSON allKeys][0];
    return [self runCode:JSON[key] forKey:key properties:properties];
}

- (id)runSuite:(NSArray *)suite {
    return [self runSuite:suite properties:[NSMutableDictionary dictionary]];
}

- (id)runSuite:(NSArray *)suite properties:(NSMutableDictionary *)properties {
    __block id returnValue = nil;
    [suite enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = [obj allKeys][0];
        returnValue = [self runCode:obj[key] forKey:key properties:properties];
    }];
    
    return returnValue;
}

- (id)runCode:(id)code forKey:(NSString *)key properties:(NSMutableDictionary *)properties {
    if ([key isEqualToString:@"program"] || [key isEqualToString:@"suite"]) {
        return [self runSuite:code properties:properties];
    }
    
    else if ([key isEqualToString:@"set"]) {
        properties[code[0]] = [self evaluateExpression:code[1] properties:properties];
    }
    
    else if ([key isEqualToString:@"if"]) {
        if ([[self evaluateExpression:code[@"test"] properties:properties] boolValue]) {
            return [self runSuite:code[@"true"]];
        } else {
            return [self runSuite:code[@"false"]];
        }
    }

    else {
        return [self evaluateExpression:@{ key: code } properties:properties];
    }

    return nil;
}

- (id)evaluateExpression:(id)expression properties:(NSMutableDictionary *)properties {
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
            return [self evaluateExpression:obj properties:properties];
        }];

        if (code[@"async"] && [code[@"async"] boolValue]) {
            __block id returnValue = nil;
            id (^method)(NSArray *, void(^)(id)) = _methods[code[@"method"]];

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
        NSInteger first = [[self evaluateExpression:code[0] properties:properties] integerValue];
        NSInteger second = [[self evaluateExpression:code[1] properties:properties] integerValue];
        
        return @(first + second);
    }
    
    else if ([key isEqualToString:@"=="]) {
        id firstExpression = [self evaluateExpression:code[0] properties:properties];
        id secondExpression = [self evaluateExpression:code[1] properties:properties];
        
        if ([firstExpression isEqual:secondExpression])
            return @YES;
        else
            return @NO;
    }
    
    else if ([key isEqualToString:@"get"]) {
        return properties[code];
    }
    
//    else {
//        NSAssert(false, ([NSString stringWithFormat:@"Error: attempted to run unknown code key: %@", key]));
//    }
    return nil;
}

- (void)loadMethod:(NSDictionary *)method {
    [_methods setObject:method[@"block"] forKey:method[@"name"]];
}

- (void)loadObjects:(NSArray *)objects{
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_objects setObject:obj forKey:obj[@"id"]];
    }];
}

- (void)registerEvent:(NSString *)event handler:(NSDictionary *)handler {
    [_events setObject:handler forKey:event];
}

- (void)triggerEvent:(NSString *)event {
    [self runJSON:_events[event]];
}

@end
