//
//  ZSZuseHubMySharedProjectDetailViewController.m
//  Zuse
//
//  Shows the project detail for the projects that the user has shared.
//
//  Created by Sarah Hong on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubMySharedProjectDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZSZuseHubMySharedProjectDetailViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timesDownloadedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;

@end

@implementation ZSZuseHubMySharedProjectDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor zuseBackgroundGrey];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupData];
}

- (void)setupData
{
    [self.jsonClientManager getUsersSharedSingleProject:self.uuid completion:^(NSDictionary *project, NSInteger statusCode) {
            if(project)
            {
                self.project = project;
                self.titleBar.title = self.project[@"title"];
                self.descriptionLabel.text = self.project[@"description"];
                long downloads = [self.project[@"downloads"] longLongValue];
                self.timesDownloadedLabel.text = [[NSNumber numberWithLong:downloads] stringValue];
                [self.screenshotImageView setImageWithURL:[NSURL URLWithString:self.project[@"screenshot_url"]] placeholderImage:[UIImage imageNamed:@"blank_project.png"]];
                
            }
            else
            {
                //TODO display message for the user
            }
    }];
}

- (IBAction)backTapped:(id)sender {
    self.didFinish();
}

- (IBAction)deleteTapped:(id)sender {
    [self.jsonClientManager deleteSharedProject:self.project[@"uuid"] completion:^(BOOL success, NSInteger statusCode) {
        //delete failed
        if(!success)
        {
            //not logged in
            if(statusCode == 401)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Failed"
                                                                message:@"You must sign in to delete."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self showLoginRegisterPage];
            }
            //trying to delete another user's project
            else if(statusCode == 403)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Failed"
                                                                message:@"You are not allowed delete this project."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
    self.didFinish();
}

@end
