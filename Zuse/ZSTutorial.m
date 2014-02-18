#import "ZSTutorial.h"

@interface ZSTutorial ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSArray *allowedGestures;
@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) void (^completion)();
@property (nonatomic, strong) CMPopTipView *toolTipView;

@end

@implementation ZSTutorial

-(id)init {
    self = [super init];
    if (self) {
        _window = [[UIApplication sharedApplication] keyWindow];
        _actions = [NSMutableArray array];
        
        _overlayView = [[ZSOverlayView alloc] initWithFrame:_window.frame];
        // _overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
    return self;
}

- (void)hideMessage {
    [_toolTipView dismissAnimated:YES];
}

- (void)broadcastEvent:(NSString*)event {
    if (_active && [_event isEqualToString:event]) {
        if (_completion) {
            _completion();
        }
        [self processNextAction];
    }
}

- (void)addActionWithText:(NSString*)text forEvent:(NSString*)event activeRegion:(CGRect)activeRegion setup:(void(^)())setup completion:(void(^)())completion {
    
    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    if (text) {
        action[@"text"] = text;
    }
    if (event) {
        action[@"event"] = event;
    }
    action[@"activeRegion"] = [NSValue valueWithCGRect:activeRegion];
    if (setup) {
        action[@"setup"] = setup;
    }
    if (completion) {
        action[@"completion"] = completion;
    }
    [_actions addObject:action];
}

- (void)refresh {
    for (UIView *view in _overlayView.subviews) {
        [view removeFromSuperview];
    }
    for (UIGestureRecognizer *gestureRecognizer in _overlayView.gestureRecognizers) {
        [_overlayView removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)present {
    _active = YES;
    [_window addSubview:_overlayView];
    [self processNextAction];
}

- (void)processNextAction {
    if (_active) {
        if (_actions.count == 0) {
            [_overlayView removeFromSuperview];
            _active = NO;
        }
        else {
            [self refresh];
            NSDictionary *action = _actions[0];
            [_actions removeObjectAtIndex:0];
            
            [self processAction:action];
        }
    }
}

- (void)processAction:(NSDictionary*)action {
    if (_active) {
        _event = action[@"event"];
        _allowedGestures = action[@"allowedGestures"];
        void(^setup)() = action[@"setup"];
        _completion = action[@"completion"];
        
        _overlayView.activeRegion = [action[@"activeRegion"] CGRectValue];
        
        if (setup) {
            setup();
        }
        
        // Show tooltip view
        UIView *view = nil;
        if (_toolTipOverrideView) {
            view = _toolTipOverrideView;
        }
        else {
            view = [[UIView alloc] initWithFrame:_overlayView.activeRegion];
            // view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
            [_overlayView addSubview:view];
        }
        
        
        _toolTipView = [[CMPopTipView alloc] initWithMessage:action[@"text"]];
        _toolTipView.disableTapToDismiss = YES;
        [_toolTipView presentPointingAtView:view inView:_overlayView animated:YES];
    }
}

@end
