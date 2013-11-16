//
//  ZSInterpreter.h
//  Interpreter
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSInterpreter;

@protocol ZSInterpreterDelegate <NSObject>

- (void) interpreter:(ZSInterpreter *)interpreter
objectWithIdentifier:(NSString *)identifier
 didUpdateProperties:(NSDictionary *)properties;

@end

@interface ZSInterpreter : NSObject

+ (instancetype)interpreter;

@property (strong, nonatomic) id<ZSInterpreterDelegate> delegate;

- (id)runJSON:(NSDictionary *)JSON;
- (id)runJSONString:(NSString *)JSONString;

- (void)loadMethod:(NSDictionary *)method;

- (void)triggerEvent:(NSString *)event;
- (void)triggerEvent:(NSString *)event onObjectWithIdentifier:(NSString *)objectID;

- (void)triggerEvent:(NSString *)event
          parameters:(NSDictionary *)parameters;

- (void)  triggerEvent:(NSString *)event
onObjectWithIdentifier:(NSString *)objectID
            parameters:(NSDictionary *)parameters;

- (NSDictionary *)objects;

- (void)loadObject:(NSDictionary *)obj;

@end
