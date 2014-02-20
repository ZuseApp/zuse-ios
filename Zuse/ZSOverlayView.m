//
//  ZSOverlayView.m
//  Zuse
//
//  Created by Michael Hogenson on 2/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSOverlayView.h"

@implementation ZSOverlayView

- (id)init {
    self = [super init];
    if (self) {
        _invertActiveRegion = NO;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (_invertActiveRegion) {
        return CGRectContainsPoint(_activeRegion, point);
    }
    else {
        return !CGRectContainsPoint(_activeRegion, point);
    }
}

@end
