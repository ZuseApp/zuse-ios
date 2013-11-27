//
//  ZSSpriteTouchComponent.m
//  Zuse
//
//  Created by Sarah Hong on 11/20/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSpriteTouchComponent.h"

@implementation ZSSpriteTouchComponent

@synthesize node, enabled;

- (void)awake {
    node.userInteractionEnabled = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesBegan) _touchesBegan([touches anyObject]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesMoved) _touchesMoved([touches anyObject]);
}

@end
