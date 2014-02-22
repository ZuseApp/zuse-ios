//
//  ZSOverlayView.m
//  Zuse
//
//  Created by Michael Hogenson on 2/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSOverlayView.h"

@implementation ZSOverlayView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return !CGRectContainsPoint(_activeRegion, point);
}

@end
