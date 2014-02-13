#import "ZSTutorial.h"

@interface ZSTutorial ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *ownerView;
@property (nonatomic, strong) void(^completion)();

@end

@implementation ZSTutorial

-(id)init {
    self = [super init];
    if (self) {
        _window = [[UIApplication sharedApplication] keyWindow];
    }
    return self;
}

-(void)bindToView:(UIView*)view {
    _ownerView = view;
}

-(void)show {
    if (_ownerView) {
        _overlayView = [[UIView alloc] initWithFrame:_ownerView.frame];
        _overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
        // Add tutorial to the window as suggested at http://stackoverflow.com/a/5198983/700533
        [_window addSubview:_overlayView];
    }
}

-(void)hide {
    if (_ownerView) {
        [_overlayView removeFromSuperview];
    }
}

-(void)touchActionOn:(UIView *)view withText:(NSString*)text completetion:(void(^)())completion {
    if (_overlayView) {
        UIView *test = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
        test.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
        [test addGestureRecognizer:tapGesture];
        if (completion) {
            _completion = completion;
        }
        [_overlayView addSubview:test];
        
        CMPopTipView *testTipView = [[CMPopTipView alloc] initWithMessage:text];
        testTipView.delegate = self;
        [testTipView presentPointingAtView:test inView:_overlayView animated:YES];
        
    }
}

-(void)touch {
    if (_completion) {
        _completion();
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // Any cleanup code, such as releasing a CMPopTipView instance variable, if necessary
}

@end
