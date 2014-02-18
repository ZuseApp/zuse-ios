#import "ZSTutorial.h"

@interface ZSOverlayView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect activeRegion;

@end

@implementation ZSOverlayView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return !CGRectContainsPoint(_activeRegion, point);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end

@interface ZSTutorial ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableDictionary *gestureRecognizers;
@property (nonatomic, strong) NSArray *allowedGestures;
@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) void (^completion)();
@property (nonatomic, strong) ZSOverlayView *overlayView;

@end

@implementation ZSTutorial

-(id)init {
    self = [super init];
    if (self) {
        _window = [[UIApplication sharedApplication] keyWindow];
        _actions = [NSMutableArray array];
        _gestureRecognizers = [NSMutableDictionary dictionary];
        
        _overlayView = [[ZSOverlayView alloc] initWithFrame:_window.frame];
        _overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
    return self;
}

-(void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer forKey:(NSString*)key {
    [_gestureRecognizers setObject:gestureRecognizer forKey:key];
}

-(void)broadcastEvent:(NSString*)event {
    if ([_event isEqualToString:event]) {
        if (_completion) {
            _completion();
        }
        [self processNextAction];
    }
}

-(void)addActionWithText:(NSString*)text forEvent:(NSString*)event allowedGestures:(NSArray*)allowedGestures activeRegion:(CGRect)activeRegion completion:(void(^)())completion {
    
    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    if (text) {
        action[@"text"] = text;
    }
    if (event) {
        action[@"event"] = event;
    }
    if (allowedGestures) {
        action[@"allowedGestures"] = allowedGestures;
    }
    action[@"activeRegion"] = [NSValue valueWithCGRect:activeRegion];
    if (completion) {
        action[@"completion"] = completion;
    }
    [_actions addObject:action];
}

-(void)refresh {
    for (UIView *view in _overlayView.subviews) {
        [view removeFromSuperview];
    }
    for (UIGestureRecognizer *gestureRecognizer in _overlayView.gestureRecognizers) {
        [_overlayView removeGestureRecognizer:gestureRecognizer];
    }
}

-(void)present {
    [_window addSubview:_overlayView];
    [self processNextAction];
}

-(void)processNextAction {
    if (_actions.count == 0) {
        [_overlayView removeFromSuperview];
    }
    else {
        [self refresh];
        NSDictionary *action = _actions[0];
        [_actions removeObjectAtIndex:0];
        
        [self processAction:action];
    }
}

-(void)processAction:(NSDictionary*)action {
    _event = action[@"event"];
    _allowedGestures = action[@"allowedGestures"];
    _completion = action[@"completion"];
    
    _overlayView.activeRegion = [action[@"activeRegion"] CGRectValue];
    for (NSString *gestureKey in _allowedGestures) {
        UIGestureRecognizer *gestureRecognizer = _gestureRecognizers[gestureKey];
        if (gestureRecognizer) {
            [gestureRecognizer addTarget:self action:@selector(captureRecognizer)];
            [_overlayView addGestureRecognizer:gestureRecognizer];
        }
    }
    
    // Show tooltip view
//    CMPopTipView *testTipView = [[CMPopTipView alloc] initWithMessage:text];
//    testTipView.delegate = self;
//    testTipView.disableTapToDismiss = YES;
//    [testTipView presentPointingAtView:[[UIView alloc] initWithFrame:_activeRegion] inView:_overlayView animated:YES];
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // Any cleanup code, such as releasing a CMPopTipView instance variable, if necessary
}

@end
