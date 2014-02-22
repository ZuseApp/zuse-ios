//
//  ZS_JsonViewController.m
//  New Code Editor
//
//  Created by Vladimir on 2/19/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import "ZS_JsonViewController.h"

@interface ZS_JsonViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@end

@implementation ZS_JsonViewController

- (IBAction)backButtonTouched
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.textView.text = [NSString stringWithFormat:@"%@", self.json];
}

@end
