//
//  ZSGroupsViewController.h
//  Zuse
//
//  Created by Parker Wightman on 1/31/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSGroupsViewController : UIViewController

@property (weak, nonatomic) NSArray *sprites;
@property (weak, nonatomic) NSMutableDictionary *groups;
@property (strong, nonatomic) NSArray *canvasToolbarItems;
@property (copy, nonatomic) void(^didFinish)();
@property (copy, nonatomic) void(^viewControllerNeedsPresented)(UIViewController *);
@property (copy, nonatomic) void(^viewControllerNeedsDismissal)(UIViewController *);

@end