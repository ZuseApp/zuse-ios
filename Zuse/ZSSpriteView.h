//
//  ZSSpriteView.h
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSSpriteView : UIView

- (void)setContentFromImage:(UIImage*)image;
- (void)setContentFromText:(NSString*)text;

@property (strong, nonatomic) void(^singleTapped)();
@property (strong, nonatomic) void(^doubleTapped)();
@property (strong, nonatomic) void(^longPressed)(UILongPressGestureRecognizer *longPressedGestureRecognizer);
@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^cut)(ZSSpriteView *sprite);
@property (strong, nonatomic) void(^copy)(ZSSpriteView *sprite);
@property (strong, nonatomic) void(^paste)();
@property (strong, nonatomic) void(^delete)(ZSSpriteView *sprite);
@property (nonatomic, strong) NSMutableDictionary *spriteJSON;
@property (nonatomic, strong) UIView *content;

@end
