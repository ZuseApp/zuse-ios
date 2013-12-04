//
//  ZSSpriteTouchComponent.m
//  Zuse
//
//  Created by Sarah Hong on 11/20/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSpriteTouchComponent.h"

@interface ZSSpriteTouchComponent ()

@property (strong, nonatomic) UITouch *currentTouch;

@end

@implementation ZSSpriteTouchComponent

@synthesize node, enabled;

- (void)awake {
    node.userInteractionEnabled = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_touchesBegan) return;
    
    for (UITouch *touch in touches) {
        CGPoint sceneLocation = [touch locationInNode:self.node.scene];
        BOOL containsPoint = [self.node containsPoint:sceneLocation];
        
        if (containsPoint) {
            _currentTouch = touch;
            _touchesBegan(touch);
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_touchesMoved) return;
    
    for (UITouch *touch in touches) {
        if (_currentTouch == touch) {
            _touchesMoved(touch);
        }
    }
}

@end
