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

@interface ZSUserLoginViewController()

@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;
@property (assign, nonatomic) BOOL didLogIn;

@end

@implementation ZSUserLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.didLogIn = NO;
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
    self.didFinish(self.didLogIn);
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
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:self.jsonClientManager.token forKey:@"token"];
                
                self.didLogIn = YES;
                self.errorMsgLabel.text = @"";
                [self close];
            }
            else {
                self.errorMsgLabel.text = @"Username or password invalid";
                [self close];
            }
        } ];
    }
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
