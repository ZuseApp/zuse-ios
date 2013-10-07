//
//  INInterpreter.h
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INInterpreter : NSObject

- (void)run;
- (id)runJSON:(NSDictionary *)JSON;
- (id)runJSONString:(NSString *)JSONString;

+ (instancetype)interpreter;
- (void)loadMethod:(NSDictionary *)method;
- (void)registerEvent:(NSString *)event handler:(NSDictionary *)handler;
- (void)triggerEvent:(NSString *)event;
- (void)loadObjects:(NSArray *)objects;

@end
