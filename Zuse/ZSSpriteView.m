#import "ZSSpriteView.h"
#import "ZSTutorial.h"

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
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
    [self addGestureRecognizer:singleTapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    longPressGesture.delegate = self;
    [self addGestureRecognizer:longPressGesture];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    ZSTutorial *tutorial = [ZSTutorial sharedTutorial];
    if (!tutorial.active || [tutorial.allowedGestures containsObject:gestureRecognizer.class]) {
        return YES;
    }
    return NO;
}

- (void)singleTapRecognized {
    if (_singleTapped) {
        _singleTapped();
    }
}

- (void)longPressRecognized:(id)sender {
    UILongPressGestureRecognizer *gesture = (UILongPressGestureRecognizer*)sender;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_longPressBegan) {
            _longPressBegan(gesture);
        }
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (_longPressChanged) {
            _longPressChanged(gesture);
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_longPressEnded) {
            _longPressEnded(gesture);
        }
    }
}

- (void)panRecognized:(UIPanGestureRecognizer *) panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (_panBegan) {
            _panBegan(panGestureRecognizer);
        }
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_panMoved) {
            _panMoved(panGestureRecognizer);
        }
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
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
