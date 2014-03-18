//
//  ZSZuseHubInitViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/12/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSProject;

@interface ZSZuseHubInitViewController : UIViewController

@property (copy, nonatomic) void (^didFinish)();
@property (copy, nonatomic) void (^needsOpenProject)(ZSProject *project);

@end
