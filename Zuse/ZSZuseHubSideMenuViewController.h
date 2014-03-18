//
//  ZSZuseHubSideMenuViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MMDrawerController.h"
#import "ZSZuseHubContentViewController.h"
#import "ZSZuseHubEnums.h"



@interface ZSZuseHubSideMenuViewController : ZSZuseHubContentViewController <UITableViewDataSource,UITableViewDelegate>

@property (copy, nonatomic) void (^didSelectShareProject)();
@property (copy, nonatomic) void (^didSelectNewestProjects)();
@property (copy, nonatomic) void (^didSelectPopularProjects)();
@property (copy, nonatomic) void (^didSelectViewMySharedProjects)();
@property (copy, nonatomic) void (^didSelectBack)();
@property (copy, nonatomic) void (^didSelectLogout)();

@property (nonatomic, strong) UITableView * tableView;

@end
