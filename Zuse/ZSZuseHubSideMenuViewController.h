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

typedef NS_ENUM(NSInteger, ZSZuseHubDrawerSection){
    ZSZuseHubDrawerMyZuseHub,
    ZSZuseHubDrawerBrowseProjects,
    ZSZuseHubDrawerSectionCount,
};

@interface ZSZuseHubSideMenuViewController : ZSZuseHubContentViewController <UITableViewDataSource,UITableViewDelegate>

@property (copy, nonatomic) void (^didSelectShareProject)();
@property (copy, nonatomic) void (^didSelectNewestProjects)();
@property (copy, nonatomic) void (^didSelectViewMySharedProjects)();

@property (nonatomic, strong) UITableView * tableView;
@property NSInteger drawerWidth;

@end
