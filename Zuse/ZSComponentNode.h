//
//  ZSComponentNode.h
//  Zuse
//
//  Created by Parker Wightman on 1/29/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "SKComponentNode.h"
@import GLKit;

@interface ZSComponentNode : SKComponentNode

@property (strong, nonatomic) NSString *identifier;
@property CGVector velocity;
@property (strong, nonatomic) NSString *collisionGroup;
@property CGSize size;
@property CGFloat top, bottom, left, right;

- (BOOL)hasVelocity;
- (void)updatePosition:(CFTimeInterval)dt;
- (BOOL)collidesWidth:(ZSComponentNode *)otherSprite;
- (void)resolveCollisionWith:(ZSComponentNode *)otherSprite;

@end
