 #import "ZSCanvasViewController.h"
#import "ZSRendererViewController.h"
#import "ZSPhysicsGroupingViewController.h"
#import "ZSSpriteView.h"
#import "ZSMenuController.h"
#import "ZSSpriteController.h"
#import "ZSEditorViewController.h"
#import "ZSGrid.h"
#import "ZSCanvasView.h"
#import "ZSSettingsViewController.h"
#import "ZSAdjustControl.h"
#import "ZSTutorial.h"
#import "ZSSpriteTableViewCell.h"
#import "FXBlurView.h"

NSString * const ZSTutorialBroadcastDidDropSprite = @"ZSTutorialBroadcastDidDropSprite";
NSString * const ZSTutorialBroadcastDidDoubleTap = @"ZSTutorialBroadcastDidDoubleTap";
NSString * const ZSTutorialBroadcastDidShowToolbox = @"ZSTutorialBroadcastDidShowToolbox";
NSString * const ZSTutorialBroadcastDidHideToolbox = @"ZSTutorialBroadcastDidHideToolbox";
NSString * const ZSTutorialBroadcastDidTapPaddle = @"ZSTutorialBroadcastDidTapPaddle";

@interface ZSCanvasViewController ()

// Canvas
@property (weak, nonatomic) IBOutlet ZSCanvasView *canvasView;

// Menus
@property (weak, nonatomic) IBOutlet UITableView *spriteTable;
@property (strong, nonatomic) ZSSpriteController *spriteController;

// Grid Menu
@property (weak, nonatomic) IBOutlet ZSAdjustControl *adjustMenu;
@property (weak, nonatomic) IBOutlet UIView *rendererView;

// Sprites
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;

// Renderer
@property (strong, nonatomic) ZSRendererViewController *rendererViewController;

// Tutorial
@property (strong, nonatomic) ZSTutorial *tutorial;

// Toolbox
@property (weak, nonatomic) IBOutlet UIView *toolboxView;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;

// Toolbar
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pauseBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *groupBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *toolButton;

@end

@implementation ZSCanvasViewController

#pragma mark Override Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Tutorial
    _tutorial = [ZSTutorial sharedTutorial];
    
    // Load the project if it exists.
    if (_project) {
        // Setup delgates, sources and gestures.
        [self setupCanvas];
        [self setupTableDelegatesAndSources];
        [self setupGestures];
        [self setupAdjustMenu];
        
        // Load Sprites.
        [self loadSpritesFromProject];
    }

    // Curve the toolbox.
    [_toolboxView.layer setCornerRadius:5];
    [_adjustMenu.layer setCornerRadius:5];
    
    // Remove pause and stop from the toolbar.
    NSMutableArray *items = [_toolbar.items mutableCopy];
    [items removeObject:_pauseBarButtonItem];
    [items removeObject:_stopBarButtonItem];
    [_toolbar setItems:items];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];
    
    // TODO: Figure out the correct place to put this.  The editor may have modified the project
    // so save the project here as well.  This means that the project gets loaded and than saved
    // right away on creation as well.
    [_project write];
    [self.view setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_showTutorial) {
        CGRect ballRect = [_spriteTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        CGRect paddleRect = [_spriteTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        __block UIView *paddle1 = nil;
        __block UIView *paddle2 = nil;
        __block UIView *ball = nil;
        
        WeakSelf
        [_tutorial addActionWithText:@"Touch the toolbox icon to open the sprite toolbox."
                            forEvent:ZSTutorialBroadcastDidShowToolbox
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:[_toolbar convertRect:_toolButton.frame toView:self.view]
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"Drag a paddle sprite onto the lower part of the canvas."
                            forEvent:ZSTutorialBroadcastDidDropSprite
                     allowedGestures:@[UILongPressGestureRecognizer.class]
                        activeRegion:[_spriteTable convertRect:paddleRect toView:self.view]
                               setup:nil
                          completion:^{
                              paddle1 = [weakSelf.canvasView.subviews lastObject];
                          }];
        [_tutorial addActionWithText:@"Drag another paddle sprite onto the upper part of the canvas."
                            forEvent:ZSTutorialBroadcastDidDropSprite
                     allowedGestures:@[UILongPressGestureRecognizer.class]
                        activeRegion:[_spriteTable convertRect:paddleRect toView:self.view]
                               setup:nil
                          completion:^{
                              paddle2 = [weakSelf.canvasView.subviews lastObject];
                          }];
        [_tutorial addActionWithText:@"Drag a ball sprite onto the middle of the canvas."
                            forEvent:ZSTutorialBroadcastDidDropSprite
                     allowedGestures:@[UILongPressGestureRecognizer.class]
                        activeRegion:[_spriteTable convertRect:ballRect toView:self.view]
                               setup:nil
                          completion:^{
                              ball = [weakSelf.canvasView.subviews lastObject];
                          }];
        [_tutorial addActionWithText:@"Touch anywhere outside of the toolbox to close it."
                            forEvent:ZSTutorialBroadcastDidHideToolbox
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:_toolboxView.frame
                               setup:^{
                                   weakSelf.tutorial.overlayView.invertActiveRegion = YES;
                               }
                          completion:nil];
        [_tutorial addActionWithText:@"Touch the lower paddle to bring up the sprite editor."
                            forEvent:ZSTutorialBroadcastDidTapPaddle
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectZero
                               setup:^{
                                   weakSelf.tutorial.overlayView.activeRegion = paddle1.frame;
                               }
                          completion:nil];
        [_tutorial present];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Hide the UIMenuController if it exists and is showing.
//    if (_editMenu) {
//        [_editMenu setMenuVisible:NO animated:YES];
//    }
    
    if ([segue.identifier isEqualToString:@"renderer"]) {
        ZSRendererViewController *rendererController = (ZSRendererViewController *)segue.destinationViewController;
        rendererController.projectJSON = [_project assembledJSON];
        _rendererViewController = rendererController;
    } else if ([segue.identifier isEqualToString:@"editor"]) {
        _showTutorial = NO;
        ZSEditorViewController *editorController = (ZSEditorViewController *)segue.destinationViewController;
        editorController.spriteObject = ((ZSSpriteView *)sender).spriteJSON;
    } else if  ([segue.identifier isEqualToString:@"settings"]) {
        ZSSettingsViewController *settingsController = (ZSSettingsViewController *)segue.destinationViewController;
        settingsController.grid = ((ZSCanvasView *) self.view).grid;
    } else if ([segue.identifier isEqualToString:@"physicsGroups"]) {
        ZSPhysicsGroupingViewController *groupingController = (ZSPhysicsGroupingViewController *)segue.destinationViewController;
        
        groupingController.sprites = _project.assembledJSON[@"objects"];
        groupingController.collisionGroups = _project.assembledJSON[@"collision_groups"];
        groupingController.didFinish = ^{
            [self dismissViewControllerAnimated:NO completion:^{ }];
        };
    }
}

#pragma mark Load Sprites From Project

- (void)loadSpritesFromProject {
    NSMutableDictionary *assembledJSON = [_project assembledJSON];
    for (NSMutableDictionary *jsonObject in assembledJSON[@"objects"]) {
        [_canvasView addSpriteFromJSON:jsonObject];
    }
}

#pragma mark Canvas Setup

- (void)setupCanvas {
    WeakSelf
    
    _canvasView.spriteSingleTapped = ^(ZSSpriteView *spriteView) {
        [_tutorial broadcastEvent:ZSTutorialBroadcastDidTapPaddle];
        [self performSegueWithIdentifier:@"editor" sender:spriteView];
    };
    
    _canvasView.spriteCreated = ^(ZSSpriteView *spriteView) {
        [[_project rawJSON][@"objects"] addObject:spriteView.spriteJSON];
        [_project write];
    };
    
    _canvasView.spriteRemoved = ^(ZSSpriteView *spriteView) {
        NSMutableArray *objects = [weakSelf.project rawJSON][@"objects"];
        for (NSMutableDictionary *currentSprite in objects) {
            if (currentSprite[@"id"] == spriteView.spriteJSON[@"id"]) {
                [objects removeObject:currentSprite];
                break;
            }
        }
        [weakSelf.project write];
    };
    
    _canvasView.spriteModified = ^(ZSSpriteView *spriteView){
        [_project write];
    };
}

#pragma mark Setup Sprite Controller

- (void)setupTableDelegatesAndSources {
    _spriteController = [[ZSSpriteController alloc] init];
    _spriteTable.delegate = _spriteController;
    _spriteTable.dataSource = _spriteController;
    
    WeakSelf
    __block CGPoint offset;
    __block CGPoint currentPoint;
    __block ZSSpriteView *draggedView;
    _spriteController.longPressBegan = ^(UILongPressGestureRecognizer *panGestureRecognizer) {
        ZSSpriteView *spriteView = (ZSSpriteView*)panGestureRecognizer.view;
        NSMutableDictionary *json = [spriteView.spriteJSON deepMutableCopy];
        NSString *type = json[@"type"];
        if ([@"text" isEqualToString:type]) {
            json[@"properties"][@"text"] = @"Value";
        }
        json[@"collision_group"] = @"";
        
        // Width and height of frame can be calculated now.
        CGRect originalFrame = spriteView.content.frame;
        CGRect frame = CGRectZero;
        frame.size.width = [json[@"properties"][@"width"] floatValue];
        frame.size.height = [json[@"properties"][@"height"] floatValue];
        
        if (![@"text" isEqualToString:type]) {
            CGFloat scale = frame.size.width / spriteView.content.frame.size.width;
            offset = [panGestureRecognizer locationInView:spriteView.content];
            offset = CGPointMake(offset.x * scale, offset.y * scale);
        }
        else {
            offset = [panGestureRecognizer locationInView:spriteView];
            offset = CGPointMake(offset.x, frame.size.height / 2);
        }
        currentPoint = [panGestureRecognizer locationInView:weakSelf.canvasView];
        
        originalFrame.origin.x = currentPoint.x - offset.x;
        originalFrame.origin.y = currentPoint.y - offset.y;
        
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        draggedView = [[ZSSpriteView alloc] initWithFrame:frame];
        [draggedView setContentFromJSON:json];
        [weakSelf.canvasView addSubview:draggedView];
        
        CGFloat scale = spriteView.content.frame.size.width / frame.size.width;
        if (scale < 1) {
            draggedView.transform = CGAffineTransformMakeScale(scale, scale);
            [UIView animateWithDuration:0.25f animations:^{
                draggedView.transform = CGAffineTransformIdentity;
            }];
        }
        [weakSelf.tutorial hideMessage];
        [weakSelf hideToolbox];
    };
    
    _spriteController.longPressChanged = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
        currentPoint = [longPressGestureRecognizer locationInView:weakSelf.canvasView];
        
        CGRect frame = draggedView.frame;
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        ZSCanvasView *view = (ZSCanvasView *)weakSelf.canvasView;
        if (view.grid.dimensions.width > 1 && view.grid.dimensions.height > 1) {
            frame.origin = [view.grid adjustedPointForPoint:frame.origin];
        }
        
        draggedView.frame = frame;
    };
    
    _spriteController.longPressEnded = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
        NSMutableDictionary *json = draggedView.spriteJSON;
        
        NSMutableDictionary *newJson = [json deepMutableCopy];
        newJson[@"id"] = [[NSUUID UUID] UUIDString];
        NSMutableDictionary *properties = newJson[@"properties"];
        [[weakSelf.project rawJSON][@"objects"] addObject:newJson];
        
        CGFloat x = draggedView.frame.origin.x + (draggedView.frame.size.width / 2);
        CGFloat y = weakSelf.canvasView.frame.size.height - draggedView.frame.size.height - draggedView.frame.origin.y;
        y += draggedView.frame.size.height / 2;
        
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        
        draggedView.spriteJSON = newJson;
        [weakSelf.canvasView setupGesturesForSpriteView:draggedView withProperties:properties];
        [weakSelf.canvasView setupEditOptionsForSpriteView:draggedView];
        
        // Save the project.
        [weakSelf.project write];
        
        // Show the toolbox again.
        [weakSelf showToolbox];
        [weakSelf.tutorial broadcastEvent:ZSTutorialBroadcastDidDropSprite];
    };
}

-(void)setupGestures {
    // Blurview
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
    singleTapGesture.numberOfTapsRequired = 1;
    [_blurView addGestureRecognizer:singleTapGesture];
    
    // Adjust Menu
    __weak ZSAdjustControl *weakAdjust = _adjustMenu;
    __block CGPoint offset;
    __block CGPoint currentPoint;
    _adjustMenu.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        offset = [panGestureRecognizer locationInView:weakAdjust];
    };
    
    _adjustMenu.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        currentPoint = [panGestureRecognizer locationInView:_canvasView];
        
        CGRect frame = weakAdjust.frame;
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        weakAdjust.frame = frame;
    };
}

- (void)singleTapRecognized {
    if (!_toolboxView.hidden) {
        [self hideToolbox];
    }
}

#pragma mark Adjustment Menu

- (void)setupAdjustMenu {
    _adjustMenu.closeMenu = ^{
        [self hideAdjustMenu];
    };
}

- (void)showAdjustMenu {
    [self.view bringSubviewToFront:_adjustMenu];
    _adjustMenu.alpha = 0;
    _adjustMenu.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        _adjustMenu.alpha = 1;
    }];
}

- (void)hideAdjustMenu {
    [UIView animateWithDuration:0.25 animations:^{
        _adjustMenu.alpha = 0;
    } completion:^(BOOL finished) {
        _adjustMenu.hidden = YES;
    }];
}

#pragma mark Main Menu

- (IBAction)playProject:(id)sender {
    NSMutableArray *items = [_toolbar.items mutableCopy];
    [items insertObject:_pauseBarButtonItem atIndex:0];
    [items removeObject:_playBarButtonItem];
    if (![items containsObject:_stopBarButtonItem]) {
        [items insertObject:_stopBarButtonItem atIndex:1];
        [items removeObject:_groupBarButtonItem];
        [items removeObject:_toolBarButtonItem];
        [items removeObject:_menuBarButtonItem];
    }
    [_toolbar setItems:items animated:YES];
    
    [self.view bringSubviewToFront:self.rendererView];
    if (self.rendererView.hidden) {
        self.rendererViewController.projectJSON = [self.project assembledJSON];
        self.rendererView.hidden = NO;
        [self.rendererViewController play];
    }
    else {
        [self.rendererViewController resume];
    }
}

- (IBAction)pauseProject:(id)sender {
    NSMutableArray *items = [_toolbar.items mutableCopy];
    [items insertObject:_playBarButtonItem atIndex:0];
    [items removeObject:_pauseBarButtonItem];
    [_toolbar setItems:items animated:YES];
    
    [_rendererViewController stop];
}

- (IBAction)stopProject:(id)sender {
    NSMutableArray *items = [_toolbar.items mutableCopy];
    if ([items containsObject:_pauseBarButtonItem]) {
        [items insertObject:_playBarButtonItem atIndex:0];
        [items removeObject:_pauseBarButtonItem];
    }
    [items removeObject:_stopBarButtonItem];
    [items insertObject:_groupBarButtonItem atIndex:2];
    [items insertObject:_toolBarButtonItem atIndex:3];
    [items insertObject:_menuBarButtonItem atIndex:4];
    [_toolbar setItems:items animated:YES];
    
    [self.rendererViewController stop];
    self.rendererView.hidden = YES;
}

- (IBAction)modifyGroups:(id)sender {
    [self performSegueWithIdentifier:@"physicsGroups" sender:self];
}

- (IBAction)return:(id)sender {
    [_project write];
    if (self.didFinish) {
        self.didFinish();
    }
}

- (IBAction)showToolbox:(id)sender {
    if (!_adjustMenu.hidden) {
        [self hideAdjustMenu];
    }
    if (_toolboxView.hidden) {
        [self showToolbox];
    }
    else {
        [self hideToolbox];
    }
}

- (IBAction)showAdjustMenu:(id)sender {
    if (_adjustMenu.hidden) {
        [self showAdjustMenu];
    }
    else {
        [self hideAdjustMenu];
    }
}

#pragma mark Toolbox

- (void)showToolbox {
    [self.view bringSubviewToFront:_toolboxView];
    _toolboxView.alpha = 0;
    _toolboxView.hidden = NO;
    _blurView.alpha = 0;
    _blurView.hidden = NO;
    _blurView.blurRadius = 5;
    _blurView.tintColor = [UIColor clearColor];
    _blurView.dynamic = NO;
    [UIView animateWithDuration:0.25f animations:^{
        _toolboxView.alpha = 1;
        _blurView.alpha = 1;
    }];
    [_tutorial broadcastEvent:ZSTutorialBroadcastDidShowToolbox];
}

- (void)hideToolbox {
    [UIView animateWithDuration:0.25f animations:^{
        _toolboxView.alpha = 0;
        _blurView.alpha = 0;
    } completion:^(BOOL finished){
        _toolboxView.hidden = YES;
        _blurView.hidden = YES;
    }];
    [_tutorial broadcastEvent:ZSTutorialBroadcastDidHideToolbox];
}


@end
