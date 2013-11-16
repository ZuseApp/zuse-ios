//
//  ZSExecutionContext.h
//  Zuse
//
//  Created by Parker Wightman on 11/13/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSExecutionContext : NSObject

+ (instancetype)context;
+ (instancetype)contextWithObjectId:(NSString *)objectID
                        environment:(NSMutableDictionary *)environment;
- (instancetype)contextWithNewEnvironment;
- (instancetype)initWithObjectId:(NSString *)objectID
                     environment:(NSMutableDictionary *)environment;

@property (strong, nonatomic, readonly) NSString *objectID;
@property (strong, nonatomic, readonly) NSMutableDictionary *environment;

@end
