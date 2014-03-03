//
//  ZSProjectPersistence.h
//  Zuse
//
//  Created by Parker Wightman on 2/27/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSProject;

@interface ZSProjectPersistence : NSObject

+ (NSArray *)exampleProjectPaths;
+ (NSArray *)userProjectPaths;

+ (NSArray *)exampleProjects;
+ (NSArray *)userProjects;

+ (void)writeProject:(ZSProject *)project;

@end
