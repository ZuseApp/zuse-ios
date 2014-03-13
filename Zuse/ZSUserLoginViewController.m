//
//  ZSUserLoginViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/10/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSUserLoginViewController.h"
#import "ZSUserRegisterViewController.h"

@implementation ZSUserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (IBAction)backTapped:(id)sender {
    self.didFinish();
}

- (IBAction)loginTapped:(id)sender {
    
}

- (IBAction)registerTapped:(id)sender {
    ZSUserRegisterViewController *controller = [[UIStoryboard storyboardWithName:@"Main"
                                                                       bundle:[NSBundle mainBundle]]
                                             instantiateViewControllerWithIdentifier:@"ZuseHubRegister"];
    
    [self presentViewController:controller animated:YES completion:^{}];
    controller.didFinish = ^{
        [self dismissViewControllerAnimated:YES completion:^{ }];
        
    };
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
