//
//  ZSZuseHubDrawerViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubViewController.h"
#import "ZSZuseHubSideMenuViewController.h"
#import "ZSZuseHubBrowseViewController.h"
#import "ZSZuseHubMyHubViewController.h"
#import "MMNavigationController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "ZSZuseHubViewSharedProjectsViewController.h"

@interface ZSZuseHubViewController ()
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *view;
@property (nonatomic,strong) MMDrawerController *drawerController;
@property (strong, nonatomic) __block ZSZuseHubSideMenuViewController *leftSideDrawerViewController;
@property (strong, nonatomic) __block ZSZuseHubContentViewController *centerViewController;
@property (strong, nonatomic) __block UINavigationController *navigationController;
@property (strong, nonatomic) __block UINavigationController *leftSideNavController;
@end

@implementation ZSZuseHubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leftSideDrawerViewController = [[ZSZuseHubSideMenuViewController alloc] init];
    //the initial center view will be 10 newest projects until the user changes it
    self.centerViewController = [[ZSZuseHubBrowseViewController alloc] init];
    self.centerViewController.contentType = ZSZuseHubBrowseTypeNewest;
    
    self.navigationController = [[MMNavigationController alloc] initWithRootViewController:self.centerViewController];
    self.leftSideNavController = [[MMNavigationController alloc] initWithRootViewController:self.leftSideDrawerViewController];
    
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:self.navigationController
                             leftDrawerViewController:self.leftSideNavController];
    [self.drawerController setShowsShadow:NO];
    
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    [self setUpLeftDrawerBlocks];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIColor * tintColor = [UIColor colorWithRed:29.0/255.0
                                          green:173.0/255.0
                                           blue:234.0/255.0
                                          alpha:1.0];
    [self.window setTintColor:tintColor];
    [self.window setRootViewController:self.drawerController];
    
    [self.view addSubview:self.drawerController.view];
    
	// Do any additional setup after loading the view.
}

- (void)setUpLeftDrawerBlocks
{
    WeakSelf
    //set up the blocks
    self.leftSideDrawerViewController.didSelectBack = ^{
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
        weakSelf.didFinish();
    };
    
    self.leftSideDrawerViewController.didSelectNewestProjects = ^{
        //now set up the center views here
        weakSelf.centerViewController = [[ZSZuseHubBrowseViewController alloc] init];
        weakSelf.centerViewController.contentType = ZSZuseHubBrowseTypeNewest;
        weakSelf.navigationController = [[MMNavigationController alloc] initWithRootViewController:weakSelf.centerViewController];
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
    };
    
    self.leftSideDrawerViewController.didSelectShareProject = ^{
        weakSelf.centerViewController = [[ZSZuseHubMyHubViewController alloc] init];
        weakSelf.centerViewController.contentType = ZSZuseHubMyHubTypeShareProject;
        weakSelf.navigationController = [[MMNavigationController alloc] initWithRootViewController:weakSelf.centerViewController];
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
    };
    
    self.leftSideDrawerViewController.didSelectViewMySharedProjects = ^{
        weakSelf.centerViewController = [[ZSZuseHubViewSharedProjectsViewController alloc] init];
        weakSelf.centerViewController.contentType = ZSZuseHubMyHubTypeViewMySharedProjects;
        weakSelf.navigationController = [[MMNavigationController alloc] initWithRootViewController:weakSelf.centerViewController];
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
    };

}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"drawer appeared");
}


@end
