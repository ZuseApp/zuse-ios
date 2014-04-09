//
//  ZSGroupsViewController.m
//  Zuse
//
//  Created by Parker Wightman on 1/31/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

// CocoaPods
#import <MTBlockAlertView/MTBlockAlertView.h>
#import <WYPopoverController/WYPopoverController.h>

// Local Imports
#import "ZSProjectJSONKeys.h"
#import "ZSGroupsViewController.h"
#import "ZSCollisionsViewController.h"
#import "ZSSelectedGroupViewController.h"
#import "ZSSpriteView.h"
#import "BlocksKit.h"
#import "ZSCanvasBarButtonItem.h"
#import "ZSGeneratorView.h"
#import "ZSGroupsGeneratorView.h"

@interface ZSGroupsViewController () <WYPopoverControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem *selectedGroupItem;
@property (strong, nonatomic) UIBarButtonItem *collisionsGroupItem;
@property (strong, nonatomic) NSArray *spriteViews;
@property (strong, nonatomic) NSString *selectedGroup;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) UIView *canvasView;
@property (strong, nonatomic) ZSGroupsGeneratorView *generatorView;

@end

@implementation ZSGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSelectedGroup:self.groups.allKeys.lastObject];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.spriteViews) {
        self.canvasView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.canvasView.backgroundColor = [UIColor whiteColor];

        self.generatorView = [[ZSGroupsGeneratorView alloc] initWithFrame:self.view.bounds collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        self.generatorView.backgroundColor = [UIColor whiteColor];
        self.generatorView.generators = self.generators;
        WeakSelf
        self.generatorView.didTapSprite = ^(NSDictionary *sprite) {
            [weakSelf toggleGroupForSpriteWithIdentifier:sprite[@"id"]];
        };

        self.generatorView.isSpriteSelected = ^BOOL(NSDictionary *sprite) {
            return [sprite[ZSProjectJSONKeyGroup] isEqualToString:weakSelf.selectedGroup];
        };
        
        self.spriteViews = [self.sprites map:^id(NSDictionary *spriteJSON) {
            ZSSpriteView *spriteView = [[ZSSpriteView alloc] initWithFrame:CGRectZero];
            spriteView.frame = [self rectForSprite:spriteJSON];
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spriteViewTapped:)];
            [spriteView addGestureRecognizer:recognizer];
            [spriteView setContentFromJSON:spriteJSON];
            [self.canvasView addSubview:spriteView];
            return spriteView;
        }];
        
        [self.view addSubview:self.generatorView];
        [self.view addSubview:self.canvasView];

        // Trigger the right view to come up, probably not the best way
        // to implicitly trigger this but it is what it is.
        self.interfaceState = self.interfaceState;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self updateSelectedSprites];
                     } completion:^(BOOL finished) {
                         if (self.groups.count == 0) {
                             [[self alertViewForNewGroupWithMessage:@"Enter a name for your first group"] show];
                         }
                     }];
}

- (void)setInterfaceState:(ZSGroupsInterfaceState)interfaceState {
    _interfaceState = interfaceState;
    if (_interfaceState == ZSGroupsInterfaceStateCanvas) {
        [self.view bringSubviewToFront:self.canvasView];
    } else {
        [self.view bringSubviewToFront:self.generatorView];
    }
}

- (NSArray *)canvasToolbarItems {
    self.selectedGroupItem = [ZSCanvasBarButtonItem selectGroupButtonWithHandler:^{
        [self selectGroupButtonTapped];
    }];
    self.collisionsGroupItem = [ZSCanvasBarButtonItem collisionsButtonWithHandler:^{
        [self collisionsButtonTapped];
    }];
    return @[
             [ZSCanvasBarButtonItem addButtonWithHandler:^{
                 [self addButtonTapped];
             }],
             self.collisionsGroupItem,
             [ZSCanvasBarButtonItem flexibleBarButtonItem],
             self.selectedGroupItem,
             [ZSCanvasBarButtonItem flexibleBarButtonItem],
             [ZSCanvasBarButtonItem finishButtonWithHandler:^{
                 [self doneButtonTapped];
             }]
             ];
}

- (void)spriteViewTapped:(UITapGestureRecognizer *)recognizer {
    ZSSpriteView *spriteView = (ZSSpriteView *)recognizer.view;
    NSLog(@"Sprite tapped: %@", spriteView.spriteJSON[@"id"]);
    [self toggleGroupForSpriteWithIdentifier:spriteView.spriteJSON[@"id"]];
    [self updateSelectedSprites];
}

- (void)toggleGroupForSpriteWithIdentifier:(NSString *)identifier {
    NSArray *allSprites = [self.sprites arrayByAddingObjectsFromArray:self.generators];
    NSMutableDictionary *sprite = [allSprites match:^BOOL(NSMutableDictionary *sprite) {
        return [sprite[@"id"] isEqualToString:identifier];
    }];
    
    if ([sprite[ZSProjectJSONKeyGroup] isEqualToString:_selectedGroup]) {
        sprite[ZSProjectJSONKeyGroup] = @"";
    } else {
        sprite[ZSProjectJSONKeyGroup] = _selectedGroup;
    }
}

- (BOOL)createNewGroupWithName:(NSString *)name {
    if (name.length != 0 && !_groups[name]) {
        _groups[name] = [NSMutableArray array];
        return YES;
    }
    NSLog(@"Groups: %@", _groups);
    
    return NO;
}

- (void)setSelectedGroup:(NSString *)group {
    _selectedGroup = group;
    
    [_selectedGroupItem setTitle:_selectedGroup];
    [self updateSelectedSprites];
}

- (void)updateSelectedSprites {
    [_spriteViews each:^(ZSSpriteView *spriteView) {
        NSString *identifier = spriteView.spriteJSON[@"id"];
        NSMutableDictionary *sprite = [self.sprites match:^BOOL(NSMutableDictionary *sprite) {
            return [sprite[@"id"] isEqualToString:identifier];
        }];
        
        if ([sprite[ZSProjectJSONKeyGroup] isEqualToString:self.selectedGroup]) {
            spriteView.alpha = 1.0;
        } else {
            spriteView.alpha = 0.2;
        }
    }];
    [self.generatorView reloadData];
}

- (CGRect)rectForSprite:(NSDictionary *)sprite {
    CGRect frame = CGRectZero;
    NSDictionary *properties = sprite[@"properties"];
    
    frame.origin.x    = [properties[@"x"] floatValue];
    frame.origin.y    = [properties[@"y"] floatValue];
    frame.size.width  = [properties[@"width"] floatValue];
    frame.size.height = [properties[@"height"] floatValue];
    
    // Coordinates in the project are stored in the
    // center of the sprite and the canvas origin is
    // in the bottom left corner, so adjust for that.
    frame.origin.x -= frame.size.width / 2;
    frame.origin.y -= frame.size.height / 2;
    frame.origin.y  = self.view.frame.size.height - frame.size.height - frame.origin.y;
    
    return frame;
}

- (void)doneButtonTapped {
    self.didFinish();
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.spriteViews each:^(ZSSpriteView *spriteView) {
                             spriteView.alpha = 1.0;
                         }];
                     } completion:^(BOOL finished) {
                     }];
}
- (void)addButtonTapped {
    [[self alertViewForNewGroupWithMessage:@"Enter a name for your new group"] show];
}

- (MTBlockAlertView *)alertViewForNewGroupWithMessage:(NSString *)message {
    MTBlockAlertView *alertView = [[MTBlockAlertView alloc]
                                   initWithTitle:@"New Group"
                                         message:message
                               completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       NSString *name = [alertView textFieldAtIndex:0].text;
                                       if ([self createNewGroupWithName:name]) {
                                           [self setSelectedGroup:name];
                                       }
                                   }
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    return alertView;
}

- (void)selectGroupButtonTapped {
    ZSSelectedGroupViewController *controller = [[ZSSelectedGroupViewController alloc] init];
    controller.groupNames = self.groups.allKeys;
    
    self.popover = nil;
    
    WeakSelf
    controller.didFinish = ^(NSString *newGroup) {
        [weakSelf setSelectedGroup:newGroup];
        [weakSelf.popover dismissPopoverAnimated:YES];
    };
    
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    [self.popover presentPopoverFromBarButtonItem:self.selectedGroupItem
                         permittedArrowDirections:WYPopoverArrowDirectionAny
                                         animated:YES
                                          options:WYPopoverAnimationOptionFadeWithScale];
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController {
    self.popover.delegate = nil;
    self.popover = nil;
}


- (void)collisionsButtonTapped {
    ZSCollisionsViewController *controller = [[ZSCollisionsViewController alloc] init];
    controller.collisionGroups = self.groups;
    controller.selectedGroup   = self.selectedGroup;
    
    WeakSelf
    controller.didFinish = ^{
        [weakSelf.popover dismissPopoverAnimated:YES];
    };
    
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    [self.popover presentPopoverFromBarButtonItem:self.collisionsGroupItem
                         permittedArrowDirections:WYPopoverArrowDirectionAny
                                         animated:YES
                                          options:WYPopoverAnimationOptionFadeWithScale];
}

@end
