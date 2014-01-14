//
//  ZSNewProjectViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 1/13/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSNewProjectViewController.h"
#import "ZSProject.h"
#import "ZSCanvasViewController.h"

@interface ZSNewProjectViewController ()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (weak, nonatomic) IBOutlet UITextField *projectName;

@end

@implementation ZSNewProjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {        
        // List user created files.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsDirectory = [paths objectAtIndex:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"canvas"]) {
        ZSProject *project = [[ZSProject alloc] init];
        project.title = _projectName.text;
        
        ZSCanvasViewController *controller = (ZSCanvasViewController *)segue.destinationViewController;
        controller.project = project;
        controller.didFinish = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
}

@end
