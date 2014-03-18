//
//  ZSZuseHubBrowseProjectDetailViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSZuseHubContentViewController.h"

@interface ZSZuseHubBrowseProjectDetailViewController : ZSZuseHubContentViewController

@property (strong, nonatomic) NSDictionary *project;

@property (copy, nonatomic) void(^didFinish)();

@end
