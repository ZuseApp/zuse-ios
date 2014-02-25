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
    return self.velocity.x != 0.0 || self.velocity.y != 0.0;
}


@end


