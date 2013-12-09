//
//  ZSGestureViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 12/4/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSGestureViewController.h"

@interface ZSGestureViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

@implementation ZSGestureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
    [self.view addGestureRecognizer:singleTapGesture];
	
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized)];
    [self.view addGestureRecognizer:longPressGesture];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeftGesture];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRightGesture];
    
    UIScreenEdgePanGestureRecognizer *leftEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdgePanRecognized)];
    [leftEdgePanGesture setEdges:UIRectEdgeLeft];
    [self.view addGestureRecognizer:leftEdgePanGesture];
    
    UIScreenEdgePanGestureRecognizer *rightEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdgePanRecognized)];
    [rightEdgePanGesture setEdges:UIRectEdgeRight];
    [self.view addGestureRecognizer:rightEdgePanGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    [self.view addGestureRecognizer:panGesture];
    
    [panGesture requireGestureRecognizerToFail:rightEdgePanGesture];
    [panGesture requireGestureRecognizerToFail:leftEdgePanGesture];
}

-(void)singleTapRecognized {
    _stateLabel.text = @"Single tap recognized.";
}

-(void)doubleTapRecognized {
    _stateLabel.text = @"Double tap recognized.";
}

-(void)longPressRecognized {
    [_stateLabel setText:@"Long press recognized."];
}

-(void)swipeRecognized:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [_stateLabel setText:@"Swipe left recognized."];
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [_stateLabel setText:@"Swipe right recognized."];
    }
}

-(void)leftEdgePanRecognized {
    [_stateLabel setText:@"Left edge pan recognized."];
}

-(void)rightEdgePanRecognized {
    [_stateLabel setText:@"Right edge pan recognized."];
}

-(void)panRecognized:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        [_stateLabel setText:@"Pan gesture began."];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [_stateLabel setText:@"Pan gesture changed."];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [_stateLabel setText:@"Pan gesture ended."];
    }
}

@end
