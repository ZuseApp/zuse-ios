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
    return self.velocity.dx != 0.0f || self.velocity.dy != 0.0f;
}

- (void)updatePosition:(CFTimeInterval)dt
{
    CGPoint point = self.position;
    self.position = CGPointMake(point.x + (self.velocity.dx * dt * 1000),
                                point.y + (self.velocity.dy * dt * 1000));
}

- (BOOL)collidesWidth:(ZSComponentNode *)otherSprite
{
    if (self.left <= otherSprite.right && self.top <= otherSprite.bottom &&
        self.right >= otherSprite.left && self.bottom >= otherSprite.top)
        return YES;
    
    return NO;
}

- (void)resolveCollisionWith:(ZSComponentNode *)otherSprite
{
    ZSComponentNode *staticNode = nil;
    ZSComponentNode *dynamicNode = nil;
    
    if(![self hasVelocity] && [otherSprite hasVelocity])
    {
        staticNode = self;
        dynamicNode = otherSprite;
    }
    
    if(![otherSprite hasVelocity] && [self hasVelocity])
    {
        staticNode = otherSprite;
        dynamicNode = self;
    }
    
    if (staticNode)
    {
        CGFloat horizontalOverlap = MIN(staticNode.right, dynamicNode.right) - MAX(staticNode.left, dynamicNode.left) + 1.5f;
        CGFloat verticalOverlap = MIN(staticNode.bottom, dynamicNode.bottom) - MAX(staticNode.top, dynamicNode.top) + 1.5f;
        
        if (horizontalOverlap == verticalOverlap)
        {
            dynamicNode.velocity = CGVectorMake(dynamicNode.velocity.dx * -1, dynamicNode.velocity.dy * -1);
            
            if (dynamicNode.top <= staticNode.bottom)
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x + verticalOverlap, dynamicNode.position.y);
            }
            else
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x - verticalOverlap, dynamicNode.position.y);
            }
            if (dynamicNode.left <= staticNode.right)
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x, dynamicNode.position.y + horizontalOverlap);
            }
            else
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x, dynamicNode.position.y - horizontalOverlap);
            }
        }
        else if (horizontalOverlap > verticalOverlap)
        {
            dynamicNode.velocity = CGVectorMake(dynamicNode.velocity.dx, dynamicNode.velocity.dy * -1);
            
            if (dynamicNode.top <= staticNode.bottom)
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x + verticalOverlap, dynamicNode.position.y);
            }
            else
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x - verticalOverlap, dynamicNode.position.y);
            }
            
        }
        else if (horizontalOverlap < verticalOverlap)
        {
            dynamicNode.velocity = CGVectorMake(dynamicNode.velocity.dx * -1, dynamicNode.velocity.dy);
            
            if (dynamicNode.left <= staticNode.right)
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x, dynamicNode.position.y + horizontalOverlap);
            }
            else
            {
                dynamicNode.position = CGPointMake(dynamicNode.position.x, dynamicNode.position.y - horizontalOverlap);
            }
        }
    }
    else
    {
        CGFloat horizontalOverlap = MIN(otherSprite.right, self.right) - MAX(otherSprite.left, self.left) + 1.5f;
        CGFloat verticalOverlap = MIN(otherSprite.bottom, self.bottom) - MAX(otherSprite.top, self.top) + 1.5f;
        
        if (horizontalOverlap == verticalOverlap)
        {
            self.velocity = CGVectorMake(self.velocity.dx * -1, self.velocity.dy * -1);
            otherSprite.velocity = CGVectorMake(otherSprite.velocity.dx * -1, otherSprite.velocity.dy * -1);
            
            if (self.top <= otherSprite.bottom)
            {
                self.position = CGPointMake(self.position.x + verticalOverlap, self.position.y);
            }
            else
            {
                self.position = CGPointMake(self.position.x - verticalOverlap, self.position.y);
            }
            if (self.left <= otherSprite.right)
            {
                self.position = CGPointMake(self.position.x, self.position.y + horizontalOverlap);
            }
            else
            {
                self.position = CGPointMake(self.position.x, self.position.y - horizontalOverlap);
            }
        }
        else if (horizontalOverlap > verticalOverlap)
        {
            self.velocity = CGVectorMake(self.velocity.dx, self.velocity.dy * -1);
            otherSprite.velocity = CGVectorMake(otherSprite.velocity.dx, otherSprite.velocity.dy * -1);
            
            if (self.top <= otherSprite.bottom)
            {
                self.position = CGPointMake(self.position.x + verticalOverlap, self.position.y);
            }
            else
            {
                self.position = CGPointMake(self.position.x - verticalOverlap, self.position.y);
            }
        }
        else if (horizontalOverlap < verticalOverlap)
        {
            self.velocity = CGVectorMake(self.velocity.dx * -1, self.velocity.dy);
            otherSprite.velocity = CGVectorMake(otherSprite.velocity.dx * -1, otherSprite.velocity.dy);
            
            if (self.left <= otherSprite.right)
            {
                self.position = CGPointMake(self.position.x, self.position.y + horizontalOverlap);
            }
            else
            {
                self.position = CGPointMake(self.position.x, self.position.y - horizontalOverlap);
            }
        }
    }
}

@end


