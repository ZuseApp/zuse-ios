//
//  INInterpreter.h
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INInterpreter : NSObject

//- (void)run;
- (id)runJSON:(NSDictionary *)JSON;
- (id)runJSONString:(NSString *)JSONString;

+ (instancetype)interpreter;
- (void)loadMethod:(NSDictionary *)method;
- (void)triggerEvent:(NSString *)event;
- (void)triggerEvent:(NSString *)event onObjectWithIdentifier:(NSString *)objectID;
- (void)loadObjects:(NSArray *)objects;
- (void)loadObject:(NSDictionary *)obj;

@end
