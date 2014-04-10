//
//  ZSZuseHubContentViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSZuseHubJSONClient.h"
#import "ZSUserLoginRegisterViewController.h"

@interface ZSZuseHubContentViewController : UIViewController

@property NSInteger contentType;
@property (strong, nonatomic) ZSZuseHubJSONClient *jsonClientManager;
@property (strong, nonatomic) ZSUserLoginRegisterViewController *loginRegisterViewController;

- (void)contentSizeDidChange:(NSString*)size;
- (void)showLoginRegisterPage;

@end
