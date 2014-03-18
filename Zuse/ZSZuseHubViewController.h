//
//  ZSZuseHubDrawerViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "MMDrawerController.h"
#import "ZSZuseHubEnums.h"

@class ZSProject;

@interface ZSZuseHubViewController : UIViewController

@property (copy, nonatomic) void(^didFinish)();
@property (copy, nonatomic) void(^didDownloadProject)(ZSProject *project);

@end
