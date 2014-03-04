//
//  ZSZuseHubShareViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/4/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSZuseHubContentViewController.h"

@interface ZSZuseHubShareViewController : ZSZuseHubContentViewController <UITableViewDataSource,UITableViewDelegate>

@property (copy, nonatomic) void(^didFinish)();

@end
