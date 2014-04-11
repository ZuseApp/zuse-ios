//
//  ZSUserLoginViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/10/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSUserLoginRegisterViewController.h"
#import "ZSZuseHubJSONClient.h"
#import "ZSZuseHubViewController.h"

@interface ZSUserLoginRegisterViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;
@property (assign, nonatomic) BOOL didLogIn;

@end

@implementation ZSUserLoginRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.didLogIn = NO;
    self.jsonClientManager = [ZSZuseHubJSONClient sharedClient];
    //set to email textfield to hidden since we default on sign in
    self.emailTextField.hidden = YES;
    self.usernameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.scrollView.bounds = self.view.bounds;
    self.view.backgroundColor = [UIColor zuseBackgroundGrey];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.scrollView.contentOffset = CGPointMake(0, self.usernameTextField.frame.origin.y);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (IBAction)segmentDidChange:(id)sender {
    
    //login
    if(self.segmentControl.selectedSegmentIndex == 0)
    {
        self.emailTextField.hidden = YES;
    }
    //register
    else if(self.segmentControl.selectedSegmentIndex == 1)
    {
        self.emailTextField.hidden = NO;
    }
}
- (IBAction)cancelTapped:(id)sender {
    self.errorMsgLabel.text = @"";
    self.didFinish(self.didLogIn);
}

- (IBAction)doneTapped:(id)sender {
    self.errorMsgLabel.text = @"";
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    //login
    if(self.segmentControl.selectedSegmentIndex == 0)
    {
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
                     
                     self.didLogIn = YES;
                     self.errorMsgLabel.text = @"";
                     self.didFinish(self.didLogIn);
                 }
                 else {
                     self.errorMsgLabel.text = @"Username or password invalid";
                 }
             } ];
        }
        else
        {
            self.errorMsgLabel.text = @"Fill out all fields";
        }
    }
    //register
    else if(self.segmentControl.selectedSegmentIndex == 1)
    {
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
                    
                    self.didLogIn = YES;
                    self.errorMsgLabel.text = @"";
                    self.didFinish(self.didLogIn);
                }
                else{
                    self.errorMsgLabel.text = @"Username taken or email invalid";
                }
            }];
        }
        else{
            self.errorMsgLabel.text = @"Fill out all fields";
        }
    }
}

- (IBAction)outerViewTapped:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
