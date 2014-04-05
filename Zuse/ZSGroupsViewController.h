//
//  ZSGroupsViewController.h
//  Zuse
//
//  Created by Parker Wightman on 1/31/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZSGroupsInterfaceState) {
    ZSGroupsInterfaceStateCanvas,
    ZSGroupsInterfaceStateGenerators
};

@interface ZSGroupsViewController : UIViewController

@property (assign, nonatomic) ZSGroupsInterfaceState interfaceState;
@property (weak, nonatomic) NSArray *sprites;
@property (weak, nonatomic) NSArray *generators;
@property (weak, nonatomic) NSMutableDictionary *groups;
@property (strong, nonatomic) NSArray *canvasToolbarItems;
@property (copy, nonatomic) void(^didFinish)();
@property (copy, nonatomic) void(^viewControllerNeedsPresented)(UIViewController *);
@property (copy, nonatomic) void(^viewControllerNeedsDismissal)(UIViewController *);

@end