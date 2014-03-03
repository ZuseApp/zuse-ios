//
//  ZSZuseHubDrawerViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubDrawerViewController.h"
#import "ZSZuseHubSideMenuViewController.h"

@interface ZSZuseHubDrawerViewController ()
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) ZSZuseHubSideMenuViewController *sideMenuController;
@property (strong, nonatomic) UIViewController *contentViewController;
@property (strong, nonatomic) MMDrawerController *drawerController;
@end

@implementation ZSZuseHubDrawerViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

+ (instancetype) zuseHubController {
    ZSZuseHubDrawerViewController *controller = [[self alloc ] init];
    [controller sharedInit];
    return controller;
}

- (void) sharedInit {
    self.navController = [[UINavigationController alloc] init];
    // Put initial custom subclass here
    self.contentViewController = [[UIViewController alloc] init];
    self.sideMenuController = [[UIStoryboard storyboardWithName:@"Main"
                                                         bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SideMenu"];
    
//    [self setCenterViewController:self.navController];
//    [self setLeftDrawerViewController:self.sideMenuController];
}

- (void)setContentViewController:(UIViewController *)contentViewController {
    _contentViewController = contentViewController;
    [self.navController setViewControllers:@[self.contentViewController]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
//    [self openDrawerSide:MMDrawerSideLeft
//                animated:YES
//              completion:^(BOOL finished) {
//                  
//              }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
