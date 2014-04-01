//
//  ZSExecutionContext.m
//  Zuse
//
//  Created by Parker Wightman on 11/13/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSExecutionContext.h"

@interface ZSExecutionContext ()

@property (strong, nonatomic) NSString *objectID;
@property (strong, nonatomic) NSMutableDictionary *environment;

@end

@implementation ZSExecutionContext

+ (instancetype)context {
    return [[self alloc] init];
}

+ (instancetype)contextWithObjectId:(NSString *)objectID
                        environment:(NSMutableDictionary *)environment {
    return [[self alloc] initWithObjectId:objectID
                              environment:environment];
    
}

- (instancetype)initWithObjectId:(NSString *)objectID
                     environment:(NSMutableDictionary *)environment {
    self = [super init];
    
    if (self) {
        _objectID = objectID;
        _environment = environment;
    }
    
    return self;
}

- (instancetype)contextWithNewEnvironment {
    return [ZSExecutionContext contextWithObjectId:self.objectID
                                       environment:[NSMutableDictionary dictionaryWithDictionary:self.environment]];
}


@end
