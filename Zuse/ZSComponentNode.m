//
//  ZSComponentNode.m
//  Zuse
//
//  Created by Parker Wightman on 1/29/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSComponentNode.h"

@implementation ZSComponentNode

- (BOOL)hasVelocity
{
    return self.velocity.dx != 0.0 || self.velocity.dy != 0.0;
}

- (void)applyVelocity:(CGVector)velocity
{
    self.velocity = velocity;
}

- (BOOL)isHit:(CGFloat)x y:(CGFloat)y
{
    SKSpriteNode *sprite = self.children.firstObject;
    CGSize size = sprite.size;
    return x >= self.position.x && x <= self.position.x + size.width && y >= self.position.y && y <= self.position.y + size.height;
}

- (void)updatePosition:(CGFloat)dt
{
    CGPoint point = self.position;
    self.position = CGPointMake(point.x + (self.velocity.dx * (dt / 1000)), point.y + (self.velocity.dy * (dt / 1000)));
}

- (void)restorePosition:(CGPoint)position
{
    self.position = position;
};


@end


