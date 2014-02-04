//
//  ZSSelectedGroupViewController.h
//  Zuse
//
//  Created by Parker Wightman on 2/4/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSSelectedGroupViewController : UIViewController

@property (strong, nonatomic) NSArray *groupNames;
@property (copy, nonatomic) void(^didFinish)(NSString *newGroup);

@end
