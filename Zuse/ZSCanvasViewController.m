//
//  ZSCanvasViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/1/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCanvasViewController.h"

@interface ZSCanvasViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *spriteTable;
    @property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *screenRecognizer;
    @property (assign, nonatomic, getter = isTableViewShowing) BOOL tableViewShowing;
@end

@implementation ZSCanvasViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _screenRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(canvasPanned:)];
    // _screenRecognizer.delegate = self;
    _screenRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:_screenRecognizer];
    
    _tableViewShowing = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    BOOL result = NO;
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        result = YES;
    }
    
    return result;
}

- (IBAction)tableViewPanned:(id)sender {
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)sender;
    
    CGPoint velocity = [panRecognizer velocityInView:_spriteTable];
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        if (ABS(velocity.x) > ABS(velocity.y) && velocity.x > 0) {
            [UIView animateWithDuration:0.25 animations:^{
                _tableViewShowing = NO;
                CGRect frame = _spriteTable.frame;
                frame.origin.x += 150;
                _spriteTable.frame = frame;
            }];
        }
    }
}

- (IBAction)canvasPanned:(id)sender {
    if (_tableViewShowing) return;
    
    UIScreenEdgePanGestureRecognizer *panRecognizer = (UIScreenEdgePanGestureRecognizer *)sender;
    
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.25 animations:^{
            _tableViewShowing = YES;
            CGRect frame = _spriteTable.frame;
            frame.origin.x -= 150;
            _spriteTable.frame = frame;
        }];
    }
}

@end
