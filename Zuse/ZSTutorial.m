#import "ZSTutorial.h"
#import <MTBlockAlertView/MTBlockAlertView.h>

NSString * const ZSTutorialBroadcastEventComplete = @"ZSTutorialBroadcastEventComplete";
NSString * const ZSTutorialBroadcastExitTutorial = @"ZSTutorialBroadcastExitTutorial";
NSString * const ZSTutorialBroadcastDebugPause = @"ZSTutorialBroadcastDebugPause";

@interface ZSTutorial ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) void (^completion)();
@property (nonatomic, strong) CMPopTipView *toolTipView;
@property (nonatomic, strong) NSMutableDictionary *savedObjects;
@property (nonatomic, assign) ZSTutorialStage lastImplementedStage;

@end

@implementation ZSTutorial

+ (id)sharedTutorial {
    static ZSTutorial *tutorial = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tutorial = [[self alloc] init];
    });
    return tutorial;
}

-(id)init {
    self = [super init];
    if (self) {
        _window = [[UIApplication sharedApplication] keyWindow];
        _actions = [NSMutableArray array];
        _savedObjects = [NSMutableDictionary dictionary];
        
        _overlayView = [[ZSOverlayView alloc] initWithFrame:_window.frame];
        // _overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
        _stage = ZSTutorialSetupStage;
        _lastImplementedStage = ZSTutorialFinalStage;
    }
    return self;
}

- (void)hideMessage {
    [self.toolTipView dismissAnimated:YES];
}

- (void)broadcastEvent:(NSString*)event {
    // If self.event is null then the tutorial isn't ready so ignore the event.
    if (!self.event) {
        return;
    }
    
    if (self.active) {
        if ([self.event isEqualToString:event]) {
            if (self.completion) {
                self.completion();
            }
            [self processNextAction];
        }
        else if ([_event isEqualToString:ZSTutorialBroadcastDebugPause]) {
            [self hideMessage];
            [self.overlayView reset];
        }
        else {
            UIAlertView *alertView = [[MTBlockAlertView alloc] initWithTitle:@"Exit Tutorial"
                                                                     message:@"Would you like to exit the tutorial?"
                                                           completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                               if (buttonIndex == 1) {
                                                                   self.active = NO;
                                                                   [_overlayView removeFromSuperview];
                                                               }
                                                           }
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:@"OK", nil];

            [alertView show];
        }
    }
}

- (void)addActionWithText:(NSString*)text forEvent:(NSString*)event allowedGestures:(NSArray*)allowedGestures activeRegion:(CGRect)activeRegion setup:(void(^)())setup completion:(void(^)())completion {
    
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
        [_overlayView reset];
        if (_actions.count == 0) {
            [_overlayView removeFromSuperview];
            if (self.stage == self.lastImplementedStage) {
                self.active = NO;
            }
            else {
                self.stage++;
            }
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
        _toolTipView = [[CMPopTipView alloc] initWithMessage:action[@"text"]];
        _toolTipView.hasGradientBackground = NO;
        _toolTipView.backgroundColor = [UIColor zuseYellow];
        _toolTipView.has3DStyle = NO;
        _toolTipView.borderWidth = 0;
        _toolTipView.hasShadow = NO;
        _toolTipView.textColor = [UIColor zuseBackgroundGrey];
        _toolTipView.delegate = self;

        UIView *view = nil;
        if (CGRectEqualToRect(_overlayView.activeRegion, CGRectZero)) {
            // If the active region is CGRectZero invert the active region and turn the tooltip into a message bubble instead.
            _toolTipView.pointerSize = 0;
            _toolTipView.dismissTapAnywhere = YES;
            view = [[UIView alloc] initWithFrame:CGRectMake(160, 20, 0, 0)];
            _overlayView.invertActiveRegion = YES;
            _overlayView.tapToDismiss = YES;
            [_overlayView addSubview:view];
        }
        else {
            _toolTipView.disableTapToDismiss = YES;
            view = [[UIView alloc] initWithFrame:_overlayView.activeRegion];
            // view.backgroundColor = [UIColor whiteColor];
            [_overlayView addSubview:view];
        }
        [_toolTipView presentPointingAtView:view inView:_overlayView animated:YES];
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [self broadcastEvent:ZSTutorialBroadcastEventComplete];
}

- (void)saveObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if ([_savedObjects objectForKey:aKey]) {
        NSLog(@"Warning: Replacing object saved for key %@", aKey);
    }
    [_savedObjects setObject:anObject forKey:aKey];
}

- (id)getObjectForKey:(id <NSCopying>)aKey {
    return _savedObjects[aKey];
}

- (void)removeObjectForKey:(id <NSCopying>)aKey {
    [_savedObjects removeObjectForKey:aKey];
}

@end
