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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Back";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close:)];
    
    
}

-(void)close:(id)sender
{
    // to dismiss use dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
    // dismissModalViewControllerAnimated: is deprecated
    
//    [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"controller dismissed"); }];
    self.didFinish();
}

- (IBAction)loginTapped:(id)sender {
    NSLog(@"login tapped");
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
