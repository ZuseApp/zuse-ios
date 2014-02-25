//
//  ZSEditorViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSEditorViewController.h"
#import "ZS_CodeEditorViewController.h"
#import "ZSTraitEditorViewController.h"

NSString * const ZSTutorialBroadcastTraitTouched = @"ZSTutorialBroadcastTraitTouched";

@interface ZSEditorViewController ()

@end

@implementation ZSEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ZS_CodeEditorViewController *codeController = (ZS_CodeEditorViewController *)self.viewControllers[0];
    codeController.json = self.spriteObject;
    
    ZSTraitEditorViewController *traitController = (ZSTraitEditorViewController *)self.viewControllers[1];
    if (!self.spriteObject[@"traits"]) {
        self.spriteObject[@"traits"] = [NSMutableDictionary dictionary];
    }
    traitController.traits = self.spriteObject[@"traits"];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:@"Traits"]) {
        [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastTraitTouched];
    }
}

#pragma mark Tutorial

- (void)createStageForName:(NSString *)name {
    if ([name isEqualToString:@"traits"]) {
        CGRect frame = CGRectMake(160, 519, 160, 49);
        [[ZSTutorial sharedTutorial] addActionWithText:@"Click here for kicks."
                                              forEvent:ZSTutorialBroadcastTraitTouched
                                       allowedGestures:@[UITapGestureRecognizer.class]
                                          activeRegion:frame
                                                 setup:nil
                                            completion:nil];
    }
}
@end
