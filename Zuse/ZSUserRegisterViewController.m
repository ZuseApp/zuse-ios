//
//  ZSUserRegisterViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/11/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSUserRegisterViewController.h"
#import "ZSAuthTokenPersistence.h"
#import "ZSZuseHubJSONClient.h"
#import "ZSZuseHubViewController.h"

@interface ZSUserRegisterViewController()

@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;

@end

@implementation ZSUserRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.jsonClientManager = [ZSZuseHubJSONClient sharedClient];
    
}
- (IBAction)registerTapped:(id)sender {
    if(self.usernameTextField.text.length != 0 &&
       self.passwordTextField.text.length != 0 &&
       self.emailTextField.text.length != 0)
    {
        NSDictionary *loginInfo = @{
                                     @"username": self.usernameTextField.text,
                                     @"email": self.emailTextField.text,
                                     @"password": self.passwordTextField.text
                                 };
        [self.jsonClientManager registerUser:loginInfo completion:^(NSDictionary *response) {
            if(response)
            {
                self.jsonClientManager.token = response[@"token"];
                [self.jsonClientManager setAuthHeader:self.jsonClientManager.token];
                [ZSAuthTokenPersistence writeTokenInfo:self.jsonClientManager.token];
                ZSZuseHubViewController *controller = [[ZSZuseHubViewController alloc] init];
                controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:controller animated:YES completion:^{}];
                controller.didFinish = ^{
                    [self close];
                };
                self.errorMsgLabel.text = @"";
            }
            else{
                self.errorMsgLabel.text = @"Username taken or email invalid";
            }
        }];
    }
}

/**
 * Closes the navigation controller so that it can return to the main menu.
 */
- (void)close
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}

@end
