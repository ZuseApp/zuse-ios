//
//  ZSZuseHubInitViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/12/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubInitViewController.h"
#import "ZSUserLoginViewController.h"
#import "ZSZuseHubViewController.h"
#import "ZSZuseHubJSONClient.h"

@interface ZSZuseHubInitViewController ()

@property (strong, nonatomic) UINavigationController *loginNavController;
@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;
@property (strong, nonatomic) ZSZuseHubViewController *hubController;

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
    if(!token)
    {
        UINavigationController *navController = [[UIStoryboard storyboardWithName:@"Main"
                                                                           bundle:[NSBundle mainBundle]]
                                                 instantiateViewControllerWithIdentifier:@"LoginNav"];
        
        ZSUserLoginViewController *loginController = (ZSUserLoginViewController *)navController.viewControllers[0];
        loginController.didFinish = ^(BOOL isLoggedIn) {
            if (isLoggedIn) {
                [self presentHubController];
            } else {
                [self close];
            }
        };
        navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:navController animated:YES completion:^{}];
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
        [weakSelf close];
    };
    
}

/**
 * Closes the navigation controller so that it can return to the main menu.
 */
- (void)close
{
    self.didFinish();
}

@end
