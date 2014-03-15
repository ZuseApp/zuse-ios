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

typedef NS_ENUM(NSInteger, ZSEditorTutorialStage) {
    ZSEditorPaddleOneSetup,
    ZSEditorPaddleTwoSetup,
    ZSEditorBallStage // Just a place holder for ZSTraitEditorParametersViewcontroller
};

@interface ZSEditorViewController ()

// Tutorial
@property (strong, nonatomic) ZSTutorial *tutorial;
@property (assign, nonatomic) ZSEditorTutorialStage tutorialStage;

@end

@implementation ZSEditorViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tutorial = [ZSTutorial sharedTutorial];
        _tutorialStage = ZSEditorPaddleOneSetup;
    }
    return self;
}

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

- (void)viewDidAppear:(BOOL)animated {
    if (_tutorial.isActive) {
        [self createTutorialForStage:_tutorialStage];
        [_tutorial presentWithCompletion:^{
            _tutorialStage++;
        }];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:@"Traits"]) {
        [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastTraitTouched];
    }
}

#pragma mark Tutorial

- (void)createTutorialForStage:(ZSEditorTutorialStage)stage {
    if (stage == ZSEditorPaddleOneSetup || stage == ZSEditorPaddleTwoSetup) {
        CGRect frame = CGRectMake(160, 519, 160, 49);
        [[ZSTutorial sharedTutorial] addActionWithText:@"Click here to toggle traits for the sprite."
                                              forEvent:ZSTutorialBroadcastTraitTouched
                                       allowedGestures:@[UITapGestureRecognizer.class]
                                          activeRegion:frame
                                                 setup:nil
                                            completion:nil];
    }
}
@end
