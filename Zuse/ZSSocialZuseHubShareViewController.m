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

@interface ZSSocialZuseHubShareViewController ()
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIButton *zuseHubButton;
@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClient;


@end

@implementation ZSSocialZuseHubShareViewController

- (id)initWithProject:(ZSProject *)project URL:(NSURL *)shareURL
{
    self.jsonClient = [ZSZuseHubJSONClient sharedClient];

    NSString *shareString = [NSString stringWithFormat:@"Check out my game %@!", project.title];
//    UIImage *shareImage = [UIImage imageNamed:@"AppIcon"];

    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareURL, nil];

    ZSZuseHubShareActivity *zuseHubShareActivity = [[ZSZuseHubShareActivity alloc] init];

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


@end
