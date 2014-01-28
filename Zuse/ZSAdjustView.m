//
//  ZSAdjustView.m
//  Zuse
//
//  Created by Michael Hogenson on 1/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSAdjustView.h"

@interface ZSAdjustView ()

@end

@implementation ZSAdjustView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        self.layer.borderWidth = 0.5f;
        [self setupGestures];
    }
    return self;
}

- (void)setupGestures {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panGesture];
}

- (void)panRecognized:(UIPanGestureRecognizer *) panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (_panBegan) {
            _panBegan(panGestureRecognizer);
        }
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_panMoved) {
            _panMoved(panGestureRecognizer);
        }
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_panEnded) {
            _panEnded(panGestureRecognizer);
        }
    }
}

@end
