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

@interface ZSSocialZuseHubShareViewController ()
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIButton *zuseHubButton;

@end

@implementation ZSSocialZuseHubShareViewController

- (id)init
{
    NSString *shareString = @"Check out the awesome game I made with Zuse!";
    UIImage *shareImage = [UIImage imageNamed:@"AppIcon"];
    
    NSArray *activityItems = [NSArray arrayWithObjects:shareString, shareImage, nil];
    
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
