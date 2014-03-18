//
//  ZSZuseHubBrowseProjectDetailViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubBrowseProjectDetailViewController.h"

@interface ZSZuseHubBrowseProjectDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleNavBar;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *timesDownloadedLabel;

@end

@implementation ZSZuseHubBrowseProjectDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                  green:208.0/255.0
                                                   blue:208.0/255.0
                                                  alpha:1.0]];

    self.titleNavBar.title = self.project[@"title"];
    self.usernameLabel.text = self.project[@"username"];
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

- (IBAction)downloadTapped:(id)sender {
    [self.jsonClientManager downloadProject:self.project[@"uuid"] completion:^(NSDictionary *project) {
        if(project)
        {
            //TODO store this project on the user's device so that it can be played.
        }
        else{
            //TODO put msg for user to indicate that download failed
        }
    }];
    
}

@end
