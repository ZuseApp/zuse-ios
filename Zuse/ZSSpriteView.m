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

- (void)setContent:(UIView *)content {
    if (_content) {
        [_content removeFromSuperview];
    }
    
    _content = content;
    if (content) {
        [self addSubview:content];
    }
}

- (void)setContentFromImage:(UIImage*)image {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    self.content = imageView;
}

- (void)setContentFromText:(NSString*)text {
    UITextView *textView = [[UITextView alloc] init];
    textView.userInteractionEnabled = NO;
    textView.text = text;
    textView.layer.backgroundColor = [[UIColor lightGrayColor] CGColor];
    textView.layer.borderWidth = 0.5f;
    self.content = textView;
}

- (void)layoutSubviews {
    if (_content) {
        _content.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
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

@end
