//
//  ZSUserRegisterViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/11/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSUserRegisterViewController.h"

@implementation ZSUserRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

@end
