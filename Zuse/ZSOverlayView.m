//
//  ZSOverlayView.m
//  Zuse
//
//  Created by Michael Hogenson on 2/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSOverlayView.h"
#import "ZSTutorial.h"

@implementation ZSOverlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self becomeFirstResponder];
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastExitTutorial];
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}



@end
