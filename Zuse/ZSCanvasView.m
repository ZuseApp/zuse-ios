#import "ZSCanvasView.h"

@interface ZSCanvasView ()

// UIMenuController
@property (nonatomic, strong) UIMenuController *editMenu;
@property (nonatomic, assign) CGPoint lastTouch;
@property (nonatomic, strong) ZSSpriteView *spriteViewCopy;
@property (nonatomic, strong) ZSSpriteView *selectedSprite;

@end

@implementation ZSCanvasView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _grid = [[ZSGrid alloc] init];
        [self setupGestures];
    }
    return self;
}

#pragma mark Grid

- (void)drawRect:(CGRect)rect
{
    if (_grid) {
        UIColor *lineColor = [UIColor colorWithRed:0.86f green:0.86f blue:0.86f alpha:1];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
        CGContextSetLineWidth(context, 0.5f);
        
        _grid.size = rect.size;
        for (NSUInteger row = 0; row < _grid.dimensions.height; row++) {
            for (NSUInteger column = 0; column < _grid.dimensions.width; column++) {
                CGContextStrokeRect(context, [_grid frameForPosition:CGPointMake(column, row)]);
            }
        }
    }
}

- (IBAction)valueChanged:(id)sender {
    NSInteger value = (NSInteger)((UISlider*)sender).value + 0.5;
    ((UISlider*)sender).value = value;
    _grid.dimensions = CGSizeMake(value, 524 / (320 / value));
    [self setNeedsDisplay];
}

#pragma mark Gesture Recognizers

-(void)setupGestures {
    // Canvas gesture recognizers.
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    longPressGesture.delegate = self;
    [self addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
    [self addGestureRecognizer:singleTap];
    
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
//    [self addGestureRecognizer:pinchRecognizer];
//    pinchRecognizer.delegate = self;
//    
//    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationDetected:)];
//    [self addGestureRecognizer:rotationRecognizer];
//    rotationRecognizer.delegate = self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)singleTapRecognized {
    if (self.singleTapped) {
        self.singleTapped();
    }
}

- (void)longPressRecognized:(id)sender {
    UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer *)sender;
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [longPressGesture.view becomeFirstResponder];
        _editMenu = [UIMenuController sharedMenuController];
        [_editMenu setTargetRect:CGRectMake(_lastTouch.x, _lastTouch.y, 0, 0) inView:self];
        [_editMenu setMenuVisible:YES animated:YES];
    }
}

- (void)pinchDetected:(id)sender {
    UIPinchGestureRecognizer *pinchRecognizer = (UIPinchGestureRecognizer*)sender;
    CGFloat scale = pinchRecognizer.scale;
    self.selectedSprite.transform = CGAffineTransformScale(self.selectedSprite.transform, scale, scale);
    pinchRecognizer.scale = 1.0;
}

- (void)rotationDetected:(id)sender {
    UIRotationGestureRecognizer *rotationRecognizer = (UIRotationGestureRecognizer*)sender;
    CGFloat angle = rotationRecognizer.rotation;
    self.selectedSprite.transform = CGAffineTransformRotate(self.selectedSprite.transform, angle);
    rotationRecognizer.rotation = 0.0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouch = [[touches anyObject] locationInView:self];
    [_editMenu setMenuVisible:NO animated:YES];
}

#pragma mark Sprite Manipulation

- (void)addSpriteFromJSON:(NSMutableDictionary*)spriteJSON {
    NSMutableDictionary *properties = spriteJSON[@"properties"];
    
    CGRect frame = CGRectZero;
    frame.origin.x = [properties[@"x"] floatValue];
    frame.origin.y = [properties[@"y"] floatValue];
    frame.size.width = [properties[@"width"] floatValue];
    frame.size.height = [properties[@"height"] floatValue];
    
    // Coordinates in the project are stored in the center of the sprite and the canvas origin is
    // in the bottom left corner, so adjust for that.
    frame.origin.x -= frame.size.width / 2;
    frame.origin.y -= frame.size.height / 2;
    frame.origin.y = self.frame.size.height - frame.size.height - frame.origin.y;
    
    ZSSpriteView *view = [[ZSSpriteView alloc] initWithFrame:frame];
    if (![view setContentFromJSON:spriteJSON]) {
        // If the sprite isn't marked with a type, ignore it.
        NSLog(@"WARNING: Unkown sprite type.  Skipping adding it to canvas.");
        return;
    }
    
    [self setupGesturesForSpriteView:view withProperties:properties];
    [self setupEditOptionsForSpriteView:view];
    [self addSubview:view];
}

- (void)moveSprite:(ZSSpriteView*)spriteView x:(CGFloat)x y:(CGFloat)y {
    CGRect frame = spriteView.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    
    if (_grid.dimensions.width > 1 && _grid.dimensions.height > 1) {
        frame.origin = [_grid adjustedPointForPoint:frame.origin];
    }
    
    spriteView.frame = frame;
}

- (ZSSpriteView *)copySpriteView:(ZSSpriteView *)spriteView {
    ZSSpriteView *copy = [[ZSSpriteView alloc] initWithFrame:spriteView.frame];
    NSMutableDictionary *json = [spriteView.spriteJSON deepMutableCopy];
    json[@"id"] = [[NSUUID UUID] UUIDString];
    [copy setContentFromJSON:json];
    [self setupGesturesForSpriteView:copy withProperties:copy.spriteJSON[@"properties"]];
    [self setupEditOptionsForSpriteView:copy];
    return copy;
}

- (void)setupGesturesForSpriteView:(ZSSpriteView *)view withProperties:(NSMutableDictionary *)properties {
    
    WeakSelf
    __weak ZSSpriteView *weakView = view;

    view.singleTapped = ^() {
        [_editMenu setMenuVisible:NO animated:YES];
        if (weakSelf.selectedSprite) {
            weakSelf.selectedSprite = weakView;
            [weakSelf lockUnselectedSprites];
            if (weakSelf.spriteSelected) {
                weakSelf.spriteSelected(weakView);
            }
        }
        else {
            if (_spriteSingleTapped) {
                _spriteSingleTapped(weakView);
            }
        }
    };
    
    view.longPressBegan = ^(UILongPressGestureRecognizer *longPressedGestureRecognizer){
        weakSelf.selectedSprite = weakView;
        [weakSelf lockUnselectedSprites];
        if (weakSelf.spriteSelected) {
            weakSelf.spriteSelected(weakView);
        }
    };
    
    __block CGPoint offset;
    __block CGPoint currentPoint;
    view.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        [_editMenu setMenuVisible:NO animated:YES];
        offset = [panGestureRecognizer locationInView:panGestureRecognizer.view];
    };
    
    view.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        currentPoint = [panGestureRecognizer locationInView:self];
        
        UIView *touchView = panGestureRecognizer.view;
        CGRect frame = touchView.frame;
        
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        if (_grid.dimensions.width > 1 && _grid.dimensions.height > 1) {
            frame.origin = [weakSelf.grid adjustedPointForPoint:frame.origin];
        }
        
        touchView.frame = frame;
        
        // Update the JSON.
        CGFloat x = frame.origin.x + (frame.size.width / 2);
        CGFloat y = self.frame.size.height - frame.size.height - frame.origin.y;
        y += frame.size.height / 2;
        weakView.frame = frame;
        
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        properties[@"width"] = @(frame.size.width);
        properties[@"height"] = @(frame.size.height);
    };
    
    view.panEnded = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        if (_spriteModified) {
            _spriteModified(weakView);
        }
    };
}

- (void)setupEditOptionsForSpriteView:(ZSSpriteView *)view {
    WeakSelf
    __weak ZSSpriteView *weakView = view;
    view.delete = ^(ZSSpriteView *sprite) {
        [sprite removeFromSuperview];
        if (_spriteRemoved) {
            _spriteRemoved(sprite);
        }
    };
    
    view.copy = ^(ZSSpriteView *sprite) {
        _spriteViewCopy = [weakSelf copySpriteView:sprite];
    };
    
    view.cut = ^(ZSSpriteView *sprite) {
        _spriteViewCopy = [weakSelf copySpriteView:sprite];
        [sprite removeFromSuperview];
        if (_spriteRemoved) {
            _spriteRemoved(sprite);
        }
    };
    
    view.paste = ^(ZSSpriteView *sprite) {
        [weakSelf paste:weakView];
    };
}

#pragma mark Edit Menu

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_spriteViewCopy && action == @selector(paste:)) {
        return YES;
    }
    return NO;
}

- (void)paste:(id)sender {
    if (_spriteViewCopy) {
        CGRect frame = _spriteViewCopy.frame;
        frame.origin = CGPointMake(_lastTouch.x - frame.size.width / 2, _lastTouch.y - frame.size.height / 2);

        if (self.grid.dimensions.width > 1 && self.grid.dimensions.height > 1) {
            frame.origin = [self.grid adjustedPointForPoint:frame.origin];
        }

        CGFloat x = frame.origin.x + (frame.size.width / 2);
        CGFloat y = self.frame.size.height - frame.size.height - frame.origin.y;
        y += frame.size.height / 2;

        _spriteViewCopy.frame = frame;

        NSMutableDictionary *properties = _spriteViewCopy.spriteJSON[@"properties"];
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        properties[@"width"] = @(frame.size.width);
        properties[@"height"] = @(frame.size.height);

        [self addSubview:_spriteViewCopy];
        if (_spriteCreated) {
            _spriteCreated(_spriteViewCopy);
        }

        // Create a new _spriteViewCopy.
        _spriteViewCopy = [self copySpriteView:_spriteViewCopy];
    }
}

#pragma mark Edit Functionality

- (BOOL)inEditMode {
    if (self.selectedSprite) {
        return YES;
    }
    else {
        return NO;
    };
}

- (void)selectSprite:(ZSSpriteView *)sprite {
    self.selectedSprite = sprite;
}

- (void)cutSelectedSprite {
    if (self.selectedSprite) {
        _spriteViewCopy = [self copySpriteView:self.selectedSprite];
        [self.selectedSprite removeFromSuperview];
        if (self.spriteRemoved) {
            self.spriteRemoved(self.selectedSprite);
        }
    }
}

- (void)copySelectedSprite {
    if (self.selectedSprite) {
        _spriteViewCopy = [self copySpriteView:self.selectedSprite];
    }
}

- (void)deleteSelectedSprite {
    if (self.selectedSprite) {
        [self.selectedSprite removeFromSuperview];
        if (_spriteRemoved) {
            _spriteRemoved(self.selectedSprite);
        }
    }
}

- (void)setTextForSelectedSpriteWithText:(NSString*)text {
    if (self.selectedSprite) {
        self.selectedSprite.spriteJSON[@"properties"][@"text"] = text;
        [self.selectedSprite reloadContent];
    }
}

- (void)replaceSelectedSpriteWithJSON:(NSDictionary*)spriteJSON {
    if (self.selectedSprite) {
        self.selectedSprite.spriteJSON[@"properties"][@"width"] = spriteJSON[@"properties"][@"width"];
        self.selectedSprite.spriteJSON[@"properties"][@"height"] = spriteJSON[@"properties"][@"height"];
        self.selectedSprite.spriteJSON[@"image"] = spriteJSON[@"image"];
        
        CGRect oldFrame = self.selectedSprite.frame;
        CGRect frame = self.selectedSprite.frame;
        frame.size.width = [spriteJSON[@"properties"][@"width"] floatValue];
        frame.size.height = [spriteJSON[@"properties"][@"height"] floatValue];
        frame.origin.x -= ((frame.size.width / 2) - (oldFrame.size.width / 2));
        frame.origin.y -= ((frame.size.height / 2) - (oldFrame.size.height / 2));
        self.selectedSprite.frame = frame;
        [self.selectedSprite reloadContent];
    }
}

- (void)unselectSelectedSprite {
    self.selectedSprite = nil;
    [self unlockSprites];
}

- (void)lockUnselectedSprites {
    for (ZSSpriteView *view in self.subviews) {
        if (![view.spriteJSON[@"id"] isEqualToString:self.selectedSprite.spriteJSON[@"id"]]) {
            [view lockGestures:@[UIPanGestureRecognizer.class, UILongPressGestureRecognizer.class]];
            view.alpha = 0.2;
        }
        else {
            [view unlockGestures:@[UIPanGestureRecognizer.class, UILongPressGestureRecognizer.class]];
            view.alpha = 1;
        }
    }
}

- (void)unlockSprites {
    for (ZSSpriteView *view in self.subviews) {
        [view unlockGestures:@[UIPanGestureRecognizer.class, UILongPressGestureRecognizer.class]];
        view.alpha = 1;
    }
}

@end
