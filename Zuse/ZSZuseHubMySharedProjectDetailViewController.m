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
    [self.view setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                  green:208.0/255.0
                                                   blue:208.0/255.0
                                                  alpha:1.0]];
    // Do any additional setup after loading the view.
    self.titleBar.title = self.project[@"title"];
    self.descriptionLabel.text = self.project[@"description"];
    long downloads = [self.project[@"downloads"] longLongValue];
    self.timesDownloadedLabel.text = [[NSNumber numberWithLong:downloads] stringValue];
    UIImage *image;
    if(self.project[@"screenshot"] != NULL)
    {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:self.project[@"screenshot"] options:0];
        if(data)
        {
            image = [UIImage imageWithData:data];
        }
    }
    if(image)
        self.screenshotImageView.image = image;
    else
        self.screenshotImageView.image = [UIImage imageNamed:@"blank_project.png"];
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
