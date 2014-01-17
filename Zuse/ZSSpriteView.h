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
@property (strong, nonatomic) void(^longPressed)(UILongPressGestureRecognizer *longPressedGestureRecognizer);
@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^cut)(ZSSpriteView *sprite);
@property (strong, nonatomic) void(^copy)(ZSSpriteView *sprite);
@property (strong, nonatomic) void(^paste)(ZSSpriteView *sprite);
@property (strong, nonatomic) void(^delete)(ZSSpriteView *sprite);
@property (nonatomic, strong) NSMutableDictionary *spriteJSON;

@end
