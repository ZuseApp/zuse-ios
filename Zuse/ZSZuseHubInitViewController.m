//
//  ZSZuseHubInitViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/12/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubInitViewController.h"
#import "ZSAuthTokenPersistence.h"
#import "ZSUserLoginViewController.h"
#import "ZSZuseHubViewController.h"
#import "ZSZuseHubJSONClient.h"

@interface ZSZuseHubInitViewController ()

@property (strong, nonatomic) UINavigationController *loginNavController;
@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;

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
    NSString *token = [ZSAuthTokenPersistence getTokenInfo];
    if(!token)
    {
        UINavigationController *navController = [[UIStoryboard storyboardWithName:@"Main"
                                                   bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"LoginNav"];
        
        navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:navController animated:YES completion:^{}];

    }
    else
    {
        [self.jsonClientManager setAuthHeader:token];
        ZSZuseHubViewController *controller = [[ZSZuseHubViewController alloc] init];
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:^{}];
        controller.didFinish = ^{
            [self close];
        };
    }
}

/**
 * Closes the navigation controller so that it can return to the main menu.
 */
- (void)close
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

@end
