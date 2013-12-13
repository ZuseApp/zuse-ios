//
//  ZSMainMenuViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/11/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSMainMenuViewController.h"
#import "ZSCanvasViewController.h"

@interface ZSMainMenuViewController ()

@property (strong, nonatomic) NSString *selectedProjectPath;

@end

@implementation ZSMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"canvas"]) {
        ZSCanvasViewController *controller = (ZSCanvasViewController *)segue.destinationViewController;
        controller.projectPath = _selectedProjectPath;
        controller.didFinish = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
}

- (IBAction)newProjectTapped:(id)sender {
    _selectedProjectPath = @"new_project.json";
    [self performSegueWithIdentifier:@"canvas" sender:self];
}

- (IBAction)pongTapped:(id)sender {
    _selectedProjectPath = @"pong.json";
    [self performSegueWithIdentifier:@"canvas" sender:self];
}

@end
