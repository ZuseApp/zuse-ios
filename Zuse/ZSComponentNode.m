//
//  ZSComponentNode.m
//  Zuse
//
//  Created by Parker Wightman on 1/29/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSComponentNode.h"

@implementation ZSComponentNode

- (void)updatePosition:(CFTimeInterval)dt
{
    CGPoint point = self.position;
    self.position = CGPointMake(point.x + (self.velocity.dx * (dt * 1000)),
                                point.y + (self.velocity.dy * (dt * 1000)));
}

@end


