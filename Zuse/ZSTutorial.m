#import "ZSTutorial.h"

@interface ZSTutorial ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) void (^completion)();

@end

@implementation ZSTutorial

-(id)init {
    self = [super init];
    if (self) {
        _window = [[UIApplication sharedApplication] keyWindow];
        
        _overlayView = [[UIView alloc] initWithFrame:_window.frame];
        _overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        UIScreenEdgePanGestureRecognizer *rightEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdgePanDetected:)];
        rightEdgePanGesture.edges = UIRectEdgeRight;
        [_overlayView addGestureRecognizer:rightEdgePanGesture];
        
        _actions = [NSMutableArray array];
    }
    return self;
}

-(void)refresh {
    // Is this the only way to clear the child views?
    [[_overlayView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
        if ([action[@"action"] isEqualToString:@"touch"]) {
            [self processTouchAction:action];
        }
        else if ([action[@"action"] isEqualToString:@"rightEdgeSwipe"]) {
            [self processRightEdgeSwipeAction:action];
        }
    }
}

-(void)addTouchActionWithText:(NSString*)text setup:(void(^)())setup completion:(void(^)())completion {
    NSDictionary *action = @{@"action": @"touch",
                             @"text": (text) ? text : [NSNull null],
                             @"setup": (setup) ? [setup copy] : [NSNull null],
                             @"completion": (completion) ? [completion copy] : [NSNull null]
                             };
    [_actions addObject:action];
}

-(void)processTouchAction:(NSDictionary*)action {
    if (_overlayView) {
        NSString *text = action[@"text"];
        void (^setup)() = action[@"setup"];
        _completion = action[@"completion"];
        
        if (setup) {
            setup();
        }
        
        UIView *test = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
        test.backgroundColor = [UIColor whiteColor];
        test.layer.borderColor = [[UIColor blackColor] CGColor];
        test.layer.borderWidth = 0.5f;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchDetected)];
        [test addGestureRecognizer:tapGesture];
        [_overlayView addSubview:test];
        
        CMPopTipView *testTipView = [[CMPopTipView alloc] initWithMessage:text];
        testTipView.delegate = self;
        testTipView.disableTapToDismiss = YES;
        [testTipView presentPointingAtView:test inView:_overlayView animated:YES];
    }
}

-(void)addRightEdgeSwipeActionWithText:(NSString*)text setup:(void(^)())setup completion:(void(^)())completion {
    NSDictionary *action = @{@"action": @"rightEdgeSwipe",
                             @"text": (text) ? text : [NSNull null],
                             @"setup": (setup) ? [setup copy] : [NSNull null],
                             @"completion": (completion) ? [completion copy] : [NSNull null]
                             };
    [_actions addObject:action];
}

-(void)processRightEdgeSwipeAction:(NSDictionary*)action {
    if (_overlayView) {
        NSString *text = action[@"text"];
        void (^setup)() = action[@"setup"];
        _completion = action[@"completion"];
        
        if (setup) {
            setup();
        }
        
        CMPopTipView *testTipView = [[CMPopTipView alloc] initWithMessage:text];
        testTipView.delegate = self;
        testTipView.disableTapToDismiss = YES;
        [testTipView presentPointingAtView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)] inView:_overlayView animated:YES];
    }
}

-(void)touchDetected {
    if (_completion) {
        _completion();
        _completion = nil;
        [self processNextAction];
    }
}

-(void)rightEdgePanDetected:(UIScreenEdgePanGestureRecognizer*)edgePanRecognizer {
    if (edgePanRecognizer.state == UIGestureRecognizerStateBegan) {
        if (_completion) {
            _completion();
            _completion = nil;
            [self processNextAction];
        }
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // Any cleanup code, such as releasing a CMPopTipView instance variable, if necessary
}

@end
