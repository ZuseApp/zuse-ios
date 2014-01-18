//
//  ZSSpriteView.m
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSpriteView.h"

@implementation ZSSpriteView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.userInteractionEnabled = YES;
    [self setupGestures];
}

- (void)setupGestures {
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copy:(id)sender {
    if (_copy) {
        _copy(self);
    }
}

- (void)cut:(id)sender {
    if (_cut) {
        _cut(self);
    }
}

- (void)delete:(id)sender {
    if (_delete) {
        _delete(self);
    }
}

- (void)paste:(id)sender {
    if (_paste) {
        _paste();
    }
}

@end
