//
//  ZSPhysicsGroupingViewController.h
//  Zuse
//
//  Created by Parker Wightman on 1/31/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSPhysicsGroupingViewController : UIViewController

@property (weak, nonatomic) NSArray *sprites;
@property (weak, nonatomic) NSMutableDictionary *collisionGroups;
@property (copy, nonatomic) void(^didFinish)();

@end
