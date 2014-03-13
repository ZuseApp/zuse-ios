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

@end

@implementation ZSZuseHubInitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSDictionary *loginInfo = [ZSAuthTokenPersistence getLoginInfo];
    if(!loginInfo)
    {
        ZSUserLoginViewController *controller = [[UIStoryboard storyboardWithName:@"Main"
                                                                           bundle:[NSBundle mainBundle]]
                                                 instantiateViewControllerWithIdentifier:@"ZuseHubLogin"];
        
        [self presentViewController:controller animated:YES completion:^{}];
        controller.didFinish = ^{
            [self dismissViewControllerAnimated:YES completion:^{ }];
            self.didFinish();
        };
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
