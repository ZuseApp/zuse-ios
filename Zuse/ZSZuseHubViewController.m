//
//  ZSZuseHubDrawerViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubViewController.h"
#import "ZSZuseHubSideMenuViewController.h"
#import "ZSZuseHubBrowseNewestViewController.h"
#import "MMNavigationController.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface ZSZuseHubViewController ()
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *view;
@property (nonatomic,strong) MMDrawerController * drawerController;
@end

@implementation ZSZuseHubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ZSZuseHubSideMenuViewController * leftSideDrawerViewController = [[ZSZuseHubSideMenuViewController alloc] init];
    //the initial center view will be 10 newest projects until the user changes it
    UIViewController * centerViewController = [[ZSZuseHubBrowseNewestViewController alloc] init];
    UINavigationController * navigationController = [[MMNavigationController alloc] initWithRootViewController:centerViewController];
    
    UINavigationController * leftSideNavController = [[MMNavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:navigationController
                             leftDrawerViewController:leftSideNavController];
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
    
    
    leftSideDrawerViewController.didSelectBack = ^{
        self.didFinish();
    };
    
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

- (void)viewDidAppear:(BOOL)animated {

//    [self.drawerController openDrawerSide:MMDrawerSideLeft
//                animated:YES
//              completion:^(BOOL finished) {
//                  
//              }];
    
    NSLog(@"drawer appeared");
}


@end
