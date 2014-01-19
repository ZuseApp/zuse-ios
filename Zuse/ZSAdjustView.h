//
//  ZSAdjustView.h
//  Zuse
//
//  Created by Michael Hogenson on 1/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSAdjustView : UIView

@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer);

@end
