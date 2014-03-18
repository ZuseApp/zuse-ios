//
//  ZSZuseHubMySharedProjectDetailViewController.m
//  Zuse
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
    if(self.project[@"screenshot"] != NULL)
    {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:self.project[@"screenshot"] options:0];
        if(data)
        {
            UIImage *image = [UIImage imageWithData:data];
            self.screenshotImageView.image = image;
        }
        else
            self.screenshotImageView.image = [UIImage imageNamed:@"blank_project.png"];
    }
    else
        self.screenshotImageView.image = [UIImage imageNamed:@"blank_project.png"];
}

- (IBAction)backTapped:(id)sender {
    self.didFinish();
}

- (IBAction)deleteTapped:(id)sender {
    [self.jsonClientManager deleteSharedProject:self.project[@"uuid"] completion:^(BOOL success) {
        if(success)
        {
            //TODO display msg so user knows delete succeeded
        }
        else{
            //TODO display msg so user knows delete failed
        }
    }];
    self.didFinish();
}

@end
