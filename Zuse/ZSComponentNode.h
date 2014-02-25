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

-(BOOL)hasVelocity;
-(void)applyVelocity:(CGVector)velocity;
-(BOOL)isHit:(CGFloat)x y:(CGFloat)y;
-(void)updatePosition:(CGFloat)dt;
-(void)restorePosition:(CGPoint)position;

@end
