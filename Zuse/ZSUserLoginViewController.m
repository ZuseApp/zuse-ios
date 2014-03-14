//
//  ZSUserLoginViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/10/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSUserLoginViewController.h"
#import "ZSUserRegisterViewController.h"

@interface ZSUserLoginViewController()



@end

@implementation ZSUserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Login to ZuseHub";
    
    
    
}

- (IBAction)loginTapped:(id)sender {
    NSLog(@"login tapped");
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
