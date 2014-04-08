//
//  ZSZuseHubInitViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/12/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubInitViewController.h"
#import "ZSUserLoginRegisterViewController.h"
#import "ZSZuseHubViewController.h"
#import "ZSZuseHubJSONClient.h"

@interface ZSZuseHubInitViewController ()

@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;
@property (strong, nonatomic) ZSZuseHubViewController *hubController;
@property (strong, nonatomic) ZSUserLoginRegisterViewController *loginRegisterViewController;

@end

@implementation ZSZuseHubInitViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.jsonClientManager = [ZSZuseHubJSONClient sharedClient];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"token"];
//    NSString *token = @"WCJQjMenNnJrhqtVBXKlhvXB9JxcCqzeN6mpWS7Z";
    if(!token)
    {
        self.loginRegisterViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                                bundle:[NSBundle mainBundle]]
                                                      instantiateViewControllerWithIdentifier:@"ZuseHubLoginRegister"];
        WeakSelf
        self.loginRegisterViewController.didFinish = ^(BOOL isLoggedIn) {
            //what to do when finished logging in.
            if (isLoggedIn)
            {
                //NOTE TO SELF
                //instead of handling presenting the views from here, have them handled in main menu
                //that way the main menu can decide which view belongs in the hierarchy.
                
                [weakSelf.loginRegisterViewController dismissViewControllerAnimated:YES completion:^{
//                    [weakSelf presentHubController];
                }];
            } else
            {
                [weakSelf.loginRegisterViewController dismissViewControllerAnimated:YES completion:^{
                    weakSelf.didFinish();
                }];
                
                
            }
        };
        self.loginRegisterViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:self.loginRegisterViewController animated:YES completion:^{}];
    }
    else
    {
        [self.jsonClientManager setAuthHeader:token];
        [self presentHubController];
    }
}

- (void)presentHubController {
    self.hubController = [[ZSZuseHubViewController alloc] init];
    WeakSelf
    self.hubController.didDownloadProject = ^(ZSProject *project) {
        weakSelf.needsOpenProject(project);
    };
    self.hubController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:self.hubController animated:YES completion:^{}];
    self.hubController.didFinish = ^{
        weakSelf.didFinish();
    };
    
}

@end
