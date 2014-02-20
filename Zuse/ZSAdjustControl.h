//
//  ZSAdjustControll.h
//  Zuse
//
//  Created by Michael Hogenson on 2/5/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSAdjustControl : UIControl

@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer);

@property (nonatomic, strong) void(^closeMenu)();

@end
