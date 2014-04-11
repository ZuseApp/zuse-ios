//
//  ZSZuseHubBrowseProjectDetailViewController.m
//  Zuse
//
//  Shows the details for a selected project in the browse mode. Allows the user
//  to download the project to their device.
//
//  Created by Sarah Hong on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubBrowseProjectDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZSZuseHubBrowseProjectDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleNavBar;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *timesDownloadedLabel;

@end

@implementation ZSZuseHubBrowseProjectDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self setupData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                  green:208.0/255.0
                                                   blue:208.0/255.0
                                                  alpha:1.0]];
}

- (void)setupData
{
    [self.jsonClientManager showProjectDetail:self.uuid completion:^(NSDictionary *project) {
        if(project)
        {
            self.project = project;
            self.titleNavBar.title = self.project[@"title"];
            self.usernameLabel.text = self.project[@"username"];
            self.descriptionLabel.text = self.project[@"description"];
            long downloads = [self.project[@"downloads"] longLongValue];
            self.timesDownloadedLabel.text = [[NSNumber numberWithLong:downloads] stringValue];
            [self.screenshotImageView setImageWithURL:[NSURL URLWithString:project[@"screenshot_url"]] placeholderImage:[UIImage imageNamed:@"blank_project.png"]];
            
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

- (IBAction)downloadTapped:(id)sender {
    [self.jsonClientManager downloadProject:self.project[@"uuid"] completion:^(NSDictionary *projectJSON) {
        if(projectJSON)
        {
            NSString *JSONString = projectJSON[@"project_json"];
            NSError *error = nil;
            NSDictionary *projectJSONParsed = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                              options:0
                                                                                error:&error];
            
            assert(!error);
            
            ZSProject *project = [ZSProject projectWithJSON:projectJSONParsed];
            self.didDownloadProject(project);
        }
        else{
            //TODO put msg for user to indicate that download failed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Failed"
                                                            message:@"Unable to download project."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

@end
