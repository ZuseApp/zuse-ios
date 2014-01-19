//
//  ZSAdjustView.m
//  Zuse
//
//  Created by Michael Hogenson on 1/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSAdjustView.h"
#import <FXBlurView.h>

@interface ZSAdjustView ()

@property (weak, nonatomic) IBOutlet FXBlurView *blurView;

@end

@implementation ZSAdjustView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        [self setupGestures];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _blurView.tintColor = [UIColor whiteColor];
    _blurView.underlyingView = self.superview;
}

- (void)setupGestures {
    UITapGestureRecognizer *doubleTapGeture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized)];
    doubleTapGeture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGeture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGeture];
    [self addGestureRecognizer:singleTapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    [self addGestureRecognizer:longPressGesture];
}

- (void)singleTapRecognized {
    if (_singleTapped) {
        _singleTapped();
    }
}

- (void)doubleTapRecognized {
    if (_doubleTapped) {
        _doubleTapped();
    }
}

- (void)longPressRecognized:(id)sender {
    if (_longPressed) {
        _longPressed(sender);
    }
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
