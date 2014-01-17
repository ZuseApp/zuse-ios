//
//  ZSSpriteView.h
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSSpriteView : UIImageView

@property (strong, nonatomic) void(^singleTapped)();
@property (strong, nonatomic) void(^longPressed)();
@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer);
@property (nonatomic, strong) NSMutableDictionary *spriteJSON;

@end
