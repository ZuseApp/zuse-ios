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

@interface ZSGroupsViewController () <WYPopoverControllerDelegate>

// IBOutlets
@property (strong, nonatomic) UIBarButtonItem *selectedGroupItem;
@property (strong, nonatomic) UIBarButtonItem *collisionsGroupItem;

// Properties
@property (strong, nonatomic) NSArray *spriteViews;
@property (strong, nonatomic) NSString *selectedGroup;
@property (strong, nonatomic) WYPopoverController *popover;


@end

@implementation ZSGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setSelectedGroup:_groups.allKeys.lastObject];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!_spriteViews) {
        _spriteViews = [_sprites map:^id(NSDictionary *spriteJSON) {
            ZSSpriteView *spriteView = [[ZSSpriteView alloc] initWithFrame:CGRectZero];
            spriteView.frame = [self rectForSprite:spriteJSON];
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spriteViewTapped:)];
            [spriteView addGestureRecognizer:recognizer];
            [spriteView setContentFromJSON:spriteJSON];
            [self.view addSubview:spriteView];
            return spriteView;
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self updateSelectedSprites];
                     } completion:^(BOOL finished) {
                         if (_groups.count == 0) {
                             [[self alertViewForNewGroupWithMessage:@"Enter a name for your first group"] show];
                         }
                     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"collisions"]) {
    }
    else if ([segue.identifier isEqualToString:@"selectedGroup"]) {
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
             [ZSCanvasBarButtonItem doneButtonWithHandler:^{
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
    NSMutableDictionary *sprite = [_sprites match:^BOOL(NSMutableDictionary *sprite) {
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
        NSMutableDictionary *sprite = [_sprites match:^BOOL(NSMutableDictionary *sprite) {
            return [sprite[@"id"] isEqualToString:identifier];
        }];
        
        if ([sprite[ZSProjectJSONKeyGroup] isEqualToString:_selectedGroup]) {
            spriteView.alpha = 1.0;
        } else {
            spriteView.alpha = 0.2;
        }
    }];
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
    _didFinish();
    [UIView animateWithDuration:0.3
                     animations:^{
                         [_spriteViews each:^(ZSSpriteView *spriteView) {
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
    controller.groupNames = _groups.allKeys;
    
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
    controller.collisionGroups = _groups;
    controller.selectedGroup   = _selectedGroup;
    
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
