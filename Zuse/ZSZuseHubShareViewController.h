//
//  ZSZuseHubShareViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/4/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSZuseHubContentViewController.h"

@interface ZSZuseHubShareViewController : ZSZuseHubContentViewController

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *projectJson;
@property (strong, nonatomic) NSString *compiledCode;

@property (copy, nonatomic) void(^didFinish)();
@property (copy, nonatomic) void(^didSelectShare)();


@end
