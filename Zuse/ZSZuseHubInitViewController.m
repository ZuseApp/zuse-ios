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

@interface ZSZuseHubInitViewController ()

@property (strong, nonatomic) UINavigationController *loginNavController;

@end

@implementation ZSZuseHubInitViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Init ZuseHub";
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSDictionary *loginInfo = [ZSAuthTokenPersistence getLoginInfo];
    if(!loginInfo)
    {
        UINavigationController *navController = [[UIStoryboard storyboardWithName:@"Main"
                                                   bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"LoginNav"];
        ZSUserLoginViewController *controller = (ZSUserLoginViewController *)navController.viewControllers.firstObject;
//        ZSUserLoginViewController *controller = [[UIStoryboard storyboardWithName:@"Main"
//                                                                           bundle:[NSBundle mainBundle]]
//                                                 instantiateViewControllerWithIdentifier:@"ZuseHubLogin"];
        
//        self.loginNavController = [[UINavigationController alloc] initWithRootViewController:controller];
//        self.view = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        self.view.window.rootViewController = self.loginNavController;
        
//        [self presentViewController:self.loginNavController animated:YES completion:^{}];
        [self presentViewController:navController animated:YES completion:^{}];

    }
    else{
        ZSZuseHubViewController *controller = [[ZSZuseHubViewController alloc] init];
        [self presentViewController:controller animated:YES completion:^{}];
        controller.didFinish = ^{
            [self dismissViewControllerAnimated:YES completion:^{ }];
        };
    }
}

@end
