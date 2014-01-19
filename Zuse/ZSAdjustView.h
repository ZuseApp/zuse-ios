//
//  ZSAdjustView.h
//  Zuse
//
//  Created by Michael Hogenson on 1/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface ZSAdjustView : UIView

@property (strong, nonatomic) void(^singleTapped)();
@property (strong, nonatomic) void(^doubleTapped)();
@property (strong, nonatomic) void(^longPressed)(UILongPressGestureRecognizer *longPressedGestureRecognizer);
@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer);

@end
