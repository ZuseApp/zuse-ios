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
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIColor * tintColor = [UIColor colorWithRed:29.0/255.0
                                          green:173.0/255.0
                                           blue:234.0/255.0
                                          alpha:1.0];
    [self.window setTintColor:tintColor];
    
    self.leftSideDrawerViewController = [[ZSZuseHubSideMenuViewController alloc] init];
    //the initial center view will be 10 newest projects until the user changes it
    self.centerViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                           bundle:[NSBundle mainBundle]]
                                 instantiateViewControllerWithIdentifier:@"BrowseProjectsView"];
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
    [self.window setRootViewController:self.drawerController];
    
    [self.view addSubview:self.drawerController.view];

    
    [self setUpLeftDrawerBlocks];
    
}

- (void)setUpLeftDrawerBlocks
{
    WeakSelf
    //set up the blocks
    self.leftSideDrawerViewController.didSelectBack = ^{
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
        weakSelf.didFinish();
    };
    
    self.leftSideDrawerViewController.didSelectLogout = ^{
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"token"];
        [defaults synchronize];
        weakSelf.didFinish();
    };
    
    self.leftSideDrawerViewController.didSelectNewestProjects = ^{
        //now set up the center views here
        weakSelf.centerViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                   bundle:[NSBundle mainBundle]]
                                         instantiateViewControllerWithIdentifier:@"BrowseProjectsView"];
        ((ZSZuseHubBrowseViewController *)weakSelf.centerViewController).didDownloadProject = weakSelf.didDownloadProject;
        weakSelf.centerViewController.contentType = ZSZuseHubBrowseTypeNewest;
        weakSelf.navigationController = [[MMNavigationController alloc] initWithRootViewController:weakSelf.centerViewController];
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
    };
    
    self.leftSideDrawerViewController.didSelectPopularProjects = ^{
        //now set up the center views here
        weakSelf.centerViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                   bundle:[NSBundle mainBundle]]
                                         instantiateViewControllerWithIdentifier:@"BrowseProjectsView"];
        ((ZSZuseHubBrowseViewController *)weakSelf.centerViewController).didDownloadProject = weakSelf.didDownloadProject;
        weakSelf.centerViewController.contentType = ZSZuseHubBrowseTypePopular;
        weakSelf.navigationController = [[MMNavigationController alloc] initWithRootViewController:weakSelf.centerViewController];
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
    };
    
    self.leftSideDrawerViewController.didSelectShareProject = ^{
        weakSelf.centerViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                   bundle:[NSBundle mainBundle]]
                                         instantiateViewControllerWithIdentifier:@"MyHubView"];
        weakSelf.centerViewController.contentType = ZSZuseHubMyHubTypeShareProject;
        weakSelf.navigationController = [[MMNavigationController alloc] initWithRootViewController:weakSelf.centerViewController];
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
    };
    
    self.leftSideDrawerViewController.didSelectViewMySharedProjects = ^{
        weakSelf.centerViewController = [[UIStoryboard storyboardWithName:@"Main"
                                                                   bundle:[NSBundle mainBundle]]
                                         instantiateViewControllerWithIdentifier:@"MyHubView"];
        weakSelf.centerViewController.contentType = ZSZuseHubMyHubTypeViewMySharedProjects;
        weakSelf.navigationController = [[MMNavigationController alloc] initWithRootViewController:weakSelf.centerViewController];
        [weakSelf.leftSideDrawerViewController.mm_drawerController setCenterViewController:weakSelf.navigationController withCloseAnimation:YES completion:nil];
    };

}

@end
