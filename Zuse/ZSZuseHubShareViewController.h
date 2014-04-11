//
//  ZSZuseHubShareViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/4/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSZuseHubContentViewController.h"

@class ZSProject;

@interface ZSZuseHubShareViewController : ZSZuseHubContentViewController<UITextViewDelegate>

@property (strong, nonatomic) ZSProject *project;

@property (copy, nonatomic) void(^didFinish)(BOOL didShare);
@property (copy, nonatomic) void(^didLogIn)(BOOL isLoggedIn);

@end
