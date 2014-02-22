//
//  ZSAdjustControll.m
//  Zuse
//
//  Created by Michael Hogenson on 2/5/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSAdjustControl.h"
#import "ZSAdjustView.h"

@implementation ZSAdjustControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSArray *subviews = [[NSBundle mainBundle] loadNibNamed:@"ZSAdjustView" owner:self options:nil];
        UIView *mainView = subviews[0];
        [self setupActionsForView:(ZSAdjustView*)mainView];
        [self addSubview:mainView];
        
        self.userInteractionEnabled = YES;
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        self.layer.borderWidth = 0.5f;
        [self setupGestures];
    }
    return self;
}

- (void)setupActionsForView:(ZSAdjustView*)view {
    view.exitTapped = ^{
        if (_closeMenu) {
            _closeMenu();
        }
    };
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
