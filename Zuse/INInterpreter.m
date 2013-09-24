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

- (void)runJSON:(NSDictionary *)JSON {
    NSString *key = [JSON allKeys][0];
    [self runCode:JSON[key] forKey:key];
}

- (void)runSuite:(NSArray *)suite {
    [suite enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = [obj allKeys][0];
        [self runCode:obj[key] forKey:key];
    }];
}

- (void)runCode:(id)code forKey:(NSString *)key {
    if ([key isEqualToString:@"program"] || [key isEqualToString:@"suite"]) {
        [self runSuite:code];
    }
    
    else if ([key isEqualToString:@"call"]) {
        void (^method)(NSArray *) = _methods[code[@"method"]];
        method(code[@"args"]);
    }
    
    else if ([key isEqualToString:@"if"]) {
        if ([code[@"test"] boolValue]) {
            [self runSuite:code[@"true"]];
        }
    }
    
    else {
        NSAssert(false, ([NSString stringWithFormat:@"Error: attempted to run unknown code key: %@", key]));
    }
}

- (void)loadMethod:(NSDictionary *)method {
    [_methods setObject:method[@"block"] forKey:method[@"name"]];
}

- (void)registerEvent:(NSString *)event handler:(NSDictionary *)handler {
    [_events setObject:handler forKey:event];
}

- (void)triggerEvent:(NSString *)event {
    [self runJSON:_events[event]];
}

@end
