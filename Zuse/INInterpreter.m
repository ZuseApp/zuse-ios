//
//  INInterpreter.m
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import "INInterpreter.h"

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
    }
    
    return self;
}

- (void)runJSONString:(NSString *)JSONString
{
    NSData *data       = [NSData dataWithBytes:[JSONString UTF8String] length:JSONString.length];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:nil];
    assert(dict);
    
    return [self runJSON:dict];
}

- (void)run{
    [_objects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self runSuite:obj[@"code"] properties:[obj[@"variables"] mutableCopy]];
    }];
}

- (void)runJSON:(NSDictionary *)JSON {
    [self runJSON:JSON properties:[@{} mutableCopy]];
}

- (void)runJSON:(NSDictionary *)JSON properties:(NSMutableDictionary *)properties {
    NSString *key = [JSON allKeys][0];
    [self runCode:JSON[key] forKey:key properties:properties];
}

- (void)runSuite:(NSArray *)suite {
    [self runSuite:suite properties:[NSMutableDictionary dictionary]];
}

- (void)runSuite:(NSArray *)suite properties:(NSMutableDictionary *)properties {
    [suite enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = [obj allKeys][0];
        [self runCode:obj[key] forKey:key properties:properties];
    }];
}

- (void)runCode:(id)code forKey:(NSString *)key properties:(NSMutableDictionary *)properties {
    if ([key isEqualToString:@"program"] || [key isEqualToString:@"suite"]) {
        [self runSuite:code properties:properties];
    }
    
    else if ([key isEqualToString:@"set"]) {
        properties[code[0]] = [self evaluateExpression:code[1] properties:properties];
    }
    
    else if ([key isEqualToString:@"if"]) {
        if ([code[@"test"] boolValue]) {
            [self runSuite:code[@"true"]];
        }
    }
    
    else {
        [self evaluateExpression:@{ key: code } properties:properties];
    }
}

- (id)evaluateExpression:(id)expression properties:(NSMutableDictionary *)properties {
    NSString *key = [expression allKeys][0];
    NSDictionary *code = expression[@"key"];
    
    if ([key isEqualToString:@"call"]) {
        id (^method)(NSArray *) = _methods[code[@"method"]];
        return method(code[@"args"]);
    }
    
//    else if ([key isEqualToString::@"get"]) {
//        
//    }
    
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
