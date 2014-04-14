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

- (id)initWithProject:(ZSProject *)project
{
    self.jsonClient = [ZSZuseHubJSONClient sharedClient];
    
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

- (void)shareProject {
    NSURL *baseURL = [NSURL URLWithString:@"http://zusehub.com/api/v1/"];
    //    NSURL *baseURL = [NSURL URLWithString:@"http://128.110.74.238:3000/api/v1/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSData *projectData = [NSJSONSerialization dataWithJSONObject:self.project.assembledJSON
                                                          options:0
                                                            error:nil];
    
    
    NSString *projectString = [[NSString alloc] initWithBytes:projectData.bytes
                                                       length:projectData.length
                                                     encoding:NSUTF8StringEncoding];
    
    
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:self.project.assembledJSON
                                                       options:ZSCompilerOptionWrapInStartEvent];
    
    NSData *compiledData = [NSJSONSerialization dataWithJSONObject:compiler.compiledComponents
                                                           options:0
                                                             error:nil];
    
    NSString *compiledString = [[NSString alloc] initWithBytes:compiledData.bytes
                                                        length:compiledData.length
                                                      encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{
                             @"shared_project": @{
                                     @"title": self.project.title,
                                     @"project_json": projectString,
                                     @"compiled_components": compiledString
                                     }
                             };
    
    NSLog(@"Requesting...");
    
    [SVProgressHUD setBackgroundColor:[UIColor zuseBackgroundGrey]];
    [SVProgressHUD setForegroundColor:[UIColor zuseYellow]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [manager POST:@"shared_projects"
       parameters:params
          success:^(AFHTTPRequestOperation *operation, NSDictionary *project) {
              [SVProgressHUD dismiss];
              NSLog(@"Success! %@", project);
              
              if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                  SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                  [controller setInitialText:[NSString stringWithFormat:@"Check out my game %@ on Zuse!", self.project.title]];
                  [controller addURL:[NSURL URLWithString:project[@"url"]]];
                  [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
                      if (result == SLComposeViewControllerResultCancelled) {
                          NSLog(@"Wooohoo!");
                      }
                      [self dismissViewControllerAnimated:YES completion:^{}];
                  }];
                  [self presentViewController:controller
                                     animated:YES
                                   completion:^{
                                       
                                   }];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [SVProgressHUD dismiss];
              NSLog(@"Failed! %@", error.localizedDescription);
          }];
}

@end
