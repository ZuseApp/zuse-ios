//
//  ZSCollisionsViewController.h
//  Zuse
//
//  Created by Parker Wightman on 2/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSCollisionsViewController : UIViewController

@property (weak, nonatomic) NSMutableDictionary *collisionGroups;
@property (weak, nonatomic) NSString *selectedGroup;
@property (copy, nonatomic) void(^didFinish)();

@end
