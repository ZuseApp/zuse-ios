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
#import "ZSSpriteTraits.h"
#import "ZSZuseDSL.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@interface ZSEditorViewController ()

// Tutorial
@property (strong, nonatomic) ZSTutorial *tutorial;

@end

@implementation ZSEditorViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tutorial = [ZSTutorial sharedTutorial];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ZS_CodeEditorViewController *codeController = (ZS_CodeEditorViewController *)self.viewControllers[0];
    codeController.codeItems = self.spriteObject[@"code"];
    //codeController.initialProperties = self.spriteObject[@"properties"];
    
    ZSTraitEditorViewController *traitController = (ZSTraitEditorViewController *)self.viewControllers[1];
    if (!self.spriteObject[@"traits"]) {
        self.spriteObject[@"traits"] = [NSMutableDictionary dictionary];
    }
    traitController.enabledSpriteTraits  = self.spriteObject[@"traits"];
    traitController.projectTraits = self.projectTraits;
    traitController.globalTraits  = [ZSSpriteTraits defaultTraits];
    traitController.spriteProperties = self.spriteObject[@"properties"];

    CGFloat imageSize = 30;
    UIImage *codeImage = [[FAKIonIcons clipboardIconWithSize:imageSize] imageWithSize:CGSizeMake(imageSize, imageSize)];
    UIImage *traitImage = [[FAKIonIcons ios7PricetagIconWithSize:imageSize] imageWithSize:CGSizeMake(imageSize, imageSize)];

    UITabBarItem *codeItem = [[UITabBarItem alloc] initWithTitle:@"Code Editor"
                                                       image:codeImage
                                               selectedImage:codeImage];

    UITabBarItem *traitItem = [[UITabBarItem alloc] initWithTitle:@"Trait Editor"
                                                       image:traitImage
                                               selectedImage:traitImage];

//    [self.tabBar setBarTintColor:[UIColor zuseBackgroundGrey]];

    [codeController setTabBarItem:codeItem];
    [traitController setTabBarItem:traitItem];

}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if (_tutorial.isActive) {
        [self createTutorialForStage:_tutorial.stage];
        [self.tutorial present];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (self.tabBar.items[1] == item) {
        [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self.traitController
                                                                                               action:@selector(addTapped:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (ZS_CodeEditorViewController *)codeController {
    return (ZS_CodeEditorViewController *)self.viewControllers[0];
}

- (ZSTraitEditorViewController *)traitController {
    return (ZSTraitEditorViewController *)self.viewControllers[1];
}

#pragma mark Tutorial

- (void)createTutorialForStage:(ZSTutorialStage)stage {
//    if (stage == ZSEditorPaddleOneSetup || stage == ZSEditorPaddleTwoSetup) {
//        CGRect frame = CGRectMake(160, 519, 160, 49);
//        [[ZSTutorial sharedTutorial] addActionWithText:@"Click here to toggle traits for the sprite."
//                                              forEvent:ZSTutorialBroadcastEventComplete
//                                       allowedGestures:@[UITapGestureRecognizer.class]
//                                          activeRegion:frame
//                                                 setup:nil
//                                            completion:nil];
//    }
    if (stage == ZSTutorialBallCodeStage) {
        WeakSelf
        [_tutorial addActionWithText:@"This is the Sprite Editor. At the bottom, you can see it has two tabs, one for Code and one for Traits. We'll visit Traits in a minute."
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectZero
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"Tap the \"add new statement\" line to add some new Code."
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectMake(45, 107, 192, 23)
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"The Code Toolbox has various behaviors and code statements you can choose from. Statements are organized lines or groups of code that perform actions when executed."
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectZero
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"Tap the On Event method to add this to your sprite. A method is a chunk of code that executes a series of statements and can take in parameters. A parameter is a value that a method uses as input for variables. A variable is a holder for a value. On Event will execute the code inside it every time based on the Event passed in as a parameter."
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectMake(29, 134, 79, 29)
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"Tap this to edit the Event Toolbox."
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectMake(150, 108, 127, 21)
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"Select touch_began to make this event occur when the user touches the ball."
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectMake(29, 171, 110, 32)
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"#something about adding a move method#"
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectMake(92, 152, 182, 21)
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"Select move."
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectMake(27, 210, 57, 32)
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"#Something about direction parameter.#"
                            forEvent:ZSTutorialBroadcastEventComplete
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectMake(155, 151, 103, 22)
                               setup:nil
                          completion:^{
                              [[weakSelf codeController] scrollToRight];
                          }];
    }
}
@end
