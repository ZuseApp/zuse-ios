//
//  ZSSpriteTouchComponent.h
//  Zuse
//
//  Created by Sarah Hong on 11/20/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit-Components/SKComponents.h>
#import <SpriteKit/SpriteKit.h>

@interface ZSSpriteTouchComponent : NSObject<SKComponent>

@property (strong, nonatomic) void(^touchesBegan)(UITouch *touch);
@property (strong, nonatomic) void(^touchesMoved)(UITouch *touch);
@property (strong, nonatomic) void(^touchesEnded)(UITouch *touch);
@property (assign, nonatomic) NSInteger speed;

@end
