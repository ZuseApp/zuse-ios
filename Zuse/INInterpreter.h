//
//  INInterpreter.h
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INInterpreter : NSObject

+ (instancetype)interpreter;

- (id)runJSON:(NSDictionary *)JSON;
- (id)runJSONString:(NSString *)JSONString;

- (void)loadMethod:(NSDictionary *)method;
- (void)loadTrait:(NSDictionary *)trait;

- (void)triggerEvent:(NSString *)event;
- (void)triggerEvent:(NSString *)event onObjectWithIdentifier:(NSString *)objectID;

- (void)loadObject:(NSDictionary *)obj;

@end
