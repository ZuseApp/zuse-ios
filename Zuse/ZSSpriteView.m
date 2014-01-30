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

- (BOOL)setContentFromJSON:(NSMutableDictionary*)spriteJSON {
    self.spriteJSON = spriteJSON;
    NSString *type = spriteJSON[@"type"];
    if (type) {
        if ([@"image" isEqualToString:type]) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:spriteJSON[@"image"][@"path"]];
            self.content = imageView;
        }
        else if ([@"text" isEqualToString:type]) {
            UILabel *labelView = [[UILabel alloc] init];
            labelView.userInteractionEnabled = NO;
            labelView.text = spriteJSON[@"properties"][@"text"];
            labelView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            labelView.layer.borderWidth = 0.5f;
            [labelView setTextAlignment:NSTextAlignmentCenter];
            self.content = labelView;
        }
        else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)setThumbnailFromJSON:(NSMutableDictionary*)spriteJSON {
    self.spriteJSON = spriteJSON;
    NSString *type = spriteJSON[@"type"];
    if (type) {
        UIImageView *imageView = [[UIImageView alloc] init];
        if ([@"image" isEqualToString:type]) {
            imageView.image = [UIImage imageNamed:spriteJSON[@"image"][@"path"]];
        }
        else if ([@"text" isEqualToString:type]) {
            imageView.image = [UIImage imageNamed:@"text_icon.png"];
        }
        else {
            return NO;
        }
        self.content = imageView;
    }
    return YES;
}

- (void)layoutSubviews {
    if (_content) {
        if ([_content isKindOfClass:[UIImageView class]]) {
            NSString *type = _spriteJSON[@"type"];
            if (type) {
                CGSize viewSize = self.frame.size;
                CGSize contentSize = CGSizeZero;
                if ([@"image" isEqualToString:type]) {
                    contentSize.width = [_spriteJSON[@"properties"][@"width"] floatValue];
                    contentSize.height = [_spriteJSON[@"properties"][@"height"] floatValue];
                }
                else if ([@"text" isEqualToString:type]) {
                    UIImage *image = ((UIImageView*)_content).image;
                    contentSize = image.size;
                }
                
                float scale = MIN(viewSize.width / contentSize.width, viewSize.height / contentSize.height);
                if (scale < 1) {
                    contentSize.width *= scale;
                    contentSize.height *= scale;
                }
                
                CGRect contentFrame = _content.frame;
                contentFrame.size = contentSize;
                _content.frame = contentFrame;
            }
        }
        else {
            _content.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
        
        // Tacky, there has to be a better way.
        _content.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y);
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
