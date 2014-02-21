//
//  ZSCanvasView.h
//  Zuse
//
//  Created by Michael Hogenson on 1/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGrid.h"
#import "ZSSpriteView.h"

@interface ZSCanvasView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZSGrid *grid;

@property (strong, nonatomic) void(^spriteSingleTapped)(ZSSpriteView *spriteView);
@property (strong, nonatomic) void(^spriteCreated)(ZSSpriteView *spriteView);
@property (strong, nonatomic) void(^spriteRemoved)(ZSSpriteView *spriteView);
@property (strong, nonatomic) void(^spriteModified)(ZSSpriteView *spriteView);
- (void)addSpriteFromJSON:(NSMutableDictionary*)spriteJSON;
- (void)moveSprite:(ZSSpriteView*)spriteView x:(CGFloat)x y:(CGFloat)y;
- (void)setupGesturesForSpriteView:(ZSSpriteView *)view withProperties:(NSMutableDictionary *)properties;
- (void)setupEditOptionsForSpriteView:(ZSSpriteView *)view;

@end
