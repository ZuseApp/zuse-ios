//
//  ZSUserLoginViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/10/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSUserLoginViewController.h"
#import "ZSUserRegisterViewController.h"
#import "ZSZuseHubJSONClient.h"
#import "ZSZuseHubViewController.h"
#import "ZSAuthTokenPersistence.h"

@interface ZSUserLoginViewController()

@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;

@end

@implementation ZSUserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.jsonClientManager = [ZSZuseHubJSONClient sharedClient];
    
    self.title = @"Login to ZuseHub";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Back";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(close)];
}

/**
 * Closes the navigation controller so that it can return to the main menu.
 */
- (void)close
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)loginTapped:(id)sender {
    if(self.usernameTextField.text.length != 0 && self.passwordTextField.text.length != 0)
    {
        NSDictionary *loginInfo = @{@"username": self.usernameTextField.text,
                                    @"password": self.passwordTextField.text};
        
        [self.jsonClientManager authenticateUser:loginInfo
                                      completion:^(NSDictionary *response)
        {
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
                self.errorMsgLabel.text = @"Username or password invalid";
            }
        } ];
    }
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
