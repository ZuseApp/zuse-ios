//
//  ZSSocialZuseHubShareViewController.m
//  Zuse
//
//  Created by Sarah Hong on 4/12/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import "ZSSocialZuseHubShareViewController.h"
#import <FAKIonIcons.h>
#import "ZSZuseHubShareActivity.h"
#import "ZSCompiler.h"
#import "ZSZuseHubJSONClient.h"
#import <SVProgressHUD.h>
#import <Social/Social.h>
#import "ZSZuseHubShareViewController.h"
#import "ZSUserLoginRegisterViewController.h"

@interface ZSSocialZuseHubShareViewController ()
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIButton *zuseHubButton;
@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClient;
@property (strong, nonatomic) ZSUserLoginRegisterViewController *loginRegisterViewController;
@property (strong, nonatomic) ZSZuseHubShareViewController *controller;

@end

@implementation ZSSocialZuseHubShareViewController

- (id)initWithProject:(ZSProject *)project URL:(NSURL *)shareURL
{
    self.jsonClient = [ZSZuseHubJSONClient sharedClient];
    self.controller = [[UIStoryboard storyboardWithName:@"Main"
                                            bundle:[NSBundle mainBundle]]
                  instantiateViewControllerWithIdentifier:@"ZuseHubShare"];
    self.project = project;
    self.controller.project = project;

    NSString *shareString = [NSString stringWithFormat:@"Check out my game %@!", project.title];
//    UIImage *shareImage = [UIImage imageNamed:@"AppIcon"];

    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareURL, nil];

    ZSZuseHubShareActivity *zuseHubShareActivity = [[ZSZuseHubShareActivity alloc] init];
    
    zuseHubShareActivity.wasChosen = ^{
        [self presentViewController:self.controller animated:YES completion:^{}];
        WeakSelf
        self.controller.didFinish = ^(BOOL didShare){
            [weakSelf dismissViewControllerAnimated:YES completion:^{ }];
        };
        self.controller.didLogIn = ^(BOOL isLoggedIn){
            [weakSelf showLoginRegisterPage];
        };
    };

    self = [super initWithActivityItems:activityItems applicationActivities:@[zuseHubShareActivity]];

    if(self)
    {
        self.excludedActivityTypes = @[
                                       UIActivityTypePrint,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeMail];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *zuseHubIcon = [UIImage imageNamed:@"AppIcon"];
    self.zuseHubButton = [[UIButton alloc] init];
    [self.zuseHubButton setBackgroundImage:zuseHubIcon forState:UIControlStateNormal];
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
