//
//  ZSCanvasBarButtonItem.h
//  Zuse
//
//  Created by Parker Wightman on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FAKIcon;

@interface ZSCanvasBarButtonItem : UIBarButtonItem

@property (strong, nonatomic, readonly) UIButton *button;

+ (ZSCanvasBarButtonItem *)buttonWithIcon:(FAKIcon *)icon
                               tapHandler:(void(^)())handler;

+ (UIBarButtonItem *)flexibleBarButtonItem;

// Canvas
+ (ZSCanvasBarButtonItem *)playButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)groupsButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)toolboxButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)shareButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)backButtonWithHandler:(void (^)())handler;

// Renderer
+ (ZSCanvasBarButtonItem *)pauseButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)stopButtonWithHandler:(void (^)())handler;

@end
