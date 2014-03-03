//
//  ZSZuseHubSideMenuViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSZuseHubSideMenuViewController : UITableViewController

@property (copy, nonatomic) void (^didSelectShareProject)();
@property (copy, nonatomic) void (^didSelectNewestProjects)();
@property (copy, nonatomic) void (^didSelectViewMySharedProjects)();

@end
