//
//  ZSPhysicsGroupingViewController.m
//  Zuse
//
//  Created by Parker Wightman on 1/31/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

// CocoaPods
#import <MTBlockAlertView/MTBlockAlertView.h>

// Local Imports
#import "ZSPhysicsGroupingViewController.h"
#import "ZSCollisionsViewController.h"
#import "ZSSelectedGroupViewController.h"
#import "ZSSpriteView.h"
#import "BlocksKit.h"

@interface ZSPhysicsGroupingViewController ()

// IBOutlets
@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIView *containerSpriteView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectedGroupItem;

// Properties
@property (strong, nonatomic) NSArray *spriteViews;
@property (strong, nonatomic) NSString *selectedGroup;

@end

@implementation ZSPhysicsGroupingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUnzoomedPositions];
    
    [self setSelectedGroup:_collisionGroups.allKeys.lastObject];
    
    _spriteViews = [_sprites map:^id(NSDictionary *spriteJSON) {
        ZSSpriteView *spriteView = [[ZSSpriteView alloc] initWithFrame:CGRectZero];
        spriteView.frame = [self rectForSprite:spriteJSON];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spriteViewTapped:)];
        [spriteView addGestureRecognizer:recognizer];
        [spriteView setContentFromJSON:spriteJSON];
        [self.containerSpriteView addSubview:spriteView];
        return spriteView;
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setZoomedPositions];
                         [self updateSelectedSprites];
                     } completion:^(BOOL finished) {
                         if (_collisionGroups.count == 0) {
                             [[self alertViewForNewGroupWithMessage:@"Enter a name for your first collision group"] show];
                         }
                     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"collisions"]) {
        ZSCollisionsViewController *controller = (ZSCollisionsViewController *)segue.destinationViewController;
        controller.collisionGroups = _collisionGroups;
        controller.selectedGroup   = _selectedGroup;
        controller.didFinish       = ^{
            [self dismissViewControllerAnimated:YES completion:^{ }];
        };
    }
    else if ([segue.identifier isEqualToString:@"selectedGroup"]) {
        ZSSelectedGroupViewController *controller = (ZSSelectedGroupViewController *)segue.destinationViewController;
        controller.groupNames = _collisionGroups.allKeys;
        controller.didFinish = ^(NSString *newGroup) {
            [self setSelectedGroup:newGroup];
            [self dismissViewControllerAnimated:YES completion:^{ }];
        };
    }
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
    
    if ([sprite[@"collision_group"] isEqualToString:_selectedGroup]) {
        sprite[@"collision_group"] = @"";
    } else {
        sprite[@"collision_group"] = _selectedGroup;
    }
}

- (BOOL)createNewGroupWithName:(NSString *)name {
    if (name.length != 0 && !_collisionGroups[name]) {
        _collisionGroups[name] = [NSMutableArray array];
        return YES;
    }
    NSLog(@"Collision groups: %@", _collisionGroups);
    
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
        
        if ([sprite[@"collision_group"] isEqualToString:_selectedGroup]) {
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

- (void)setUnzoomedPositions {
    _containerSpriteView.transform = CGAffineTransformIdentity;
    
    CGRect frame = _topToolbar.frame;
    frame.origin.y = -frame.size.height;
    _topToolbar.frame = frame;
    
    frame = _bottomToolbar.frame;
    frame.origin.y = self.view.frame.size.height;
    _bottomToolbar.frame = frame;
    
}

- (void)setZoomedPositions {
    CGFloat scale = (self.view.bounds.size.height - _topToolbar.bounds.size.height * 2) / self.view.bounds.size.height;
    _containerSpriteView.transform = CGAffineTransformMakeScale(scale, scale);
    
    CGRect frame = _topToolbar.frame;
    frame.origin.y = 0;
    _topToolbar.frame = frame;
    
    frame = _bottomToolbar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    _bottomToolbar.frame = frame;
}

- (IBAction)doneButtonTapped:(id)sender {
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setUnzoomedPositions];
                         [_spriteViews each:^(ZSSpriteView *spriteView) {
                             spriteView.alpha = 1.0;
                         }];
                     } completion:^(BOOL finished) {
                         _didFinish();
                     }];
}
- (IBAction)addButtonTapped:(id)sender {
    [[self alertViewForNewGroupWithMessage:@"Enter a name for your new collision group"] show];
}

- (MTBlockAlertView *)alertViewForNewGroupWithMessage:(NSString *)message {
    MTBlockAlertView *alertView = [[MTBlockAlertView alloc]
                                   initWithTitle:@"New Collision Group"
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

- (IBAction)selectedGroupButtonTapped:(id)sender {
}

@end
