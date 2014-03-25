//
//  ZSOverlayView.m
//  Zuse
//
//  Created by Michael Hogenson on 2/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSOverlayView.h"

@implementation ZSOverlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        _invertActiveRegion = NO;
        _tapToDismiss = NO;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.tapToDismiss) {
        return YES;
    }
    if (_invertActiveRegion) {
        return CGRectContainsPoint(_activeRegion, point);
    }
    else {
        return !CGRectContainsPoint(_activeRegion, point);
    }
}

- (void)reset {
    _invertActiveRegion = NO;
    _tapToDismiss = NO;
}

@end
