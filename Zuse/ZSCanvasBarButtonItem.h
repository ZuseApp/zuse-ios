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
+ (ZSCanvasBarButtonItem *)editButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)playButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)generatorsButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)groupsButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)toolboxButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)shareButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)backButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)gridButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)menuButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)homeButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)propertiesButtonWithHandler:(void (^)())handler;

// Renderer
+ (ZSCanvasBarButtonItem *)pauseButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)stopButtonWithHandler:(void (^)())handler;

// Groups
+ (ZSCanvasBarButtonItem *)doneButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)collisionsButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)selectGroupButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)addButtonWithHandler:(void (^)())handler;

// Edit
+ (ZSCanvasBarButtonItem *)finishButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)cutButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)copyButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)deleteButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)editTextButtonWithHandler:(void (^)())handler;
+ (ZSCanvasBarButtonItem *)swapButtonWithHandler:(void (^)())handler;

@end
