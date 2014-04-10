//
//  ZSZuseHubContentViewController.m
//  Zuse
//
//  This serves as the main and generic wrapper for the content in the center view for ZuseHub
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubContentViewController.h"

@interface ZSZuseHubContentViewController ()

@end

@implementation ZSZuseHubContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.jsonClientManager = [ZSZuseHubJSONClient sharedClient];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(contentSizeDidChangeNotification:)
        name:UIContentSizeCategoryDidChangeNotification
        object:nil];
}

- (void)contentSizeDidChangeNotification:(NSNotification*)notification{
    [self contentSizeDidChange:notification.userInfo[UIContentSizeCategoryNewValueKey]];
}

- (void)contentSizeDidChange:(NSString *)size{
    //Implement in subclass
}

- (void)showLoginRegisterPage
{
    self.loginRegisterViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                  bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"ZuseHubLoginRegister"];
    WeakSelf
    self.loginRegisterViewController.didFinish = ^(BOOL isLoggedIn) {
        //what to do when finished logging in.
        if (isLoggedIn)
        {
            [weakSelf.loginRegisterViewController dismissViewControllerAnimated:YES completion:^{}];
        } else
        {
            [weakSelf.loginRegisterViewController dismissViewControllerAnimated:YES completion:^{}];
        }
    };
    self.loginRegisterViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:self.loginRegisterViewController animated:YES completion:^{}];
}

@end
