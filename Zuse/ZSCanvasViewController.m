#import "ZSCanvasViewController.h"
#import "ZSRendererViewController.h"
#import "ZSPhysicsGroupingViewController.h"
#import "ZSSpriteView.h"
#import "ZSEditorViewController.h"
#import "ZSGrid.h"
#import "ZSCanvasView.h"
#import "ZSSettingsViewController.h"
#import "FXBlurView.h"
#import "ZSToolboxController.h"
#import "UIImagePickerController+Edit.h"
#import "ZSToolboxView.h"
#import "ZSToolboxCell.h"
#import "ZSSpriteLibrary.h"

NSString * const ZSTutorialBroadcastDidDropSprite = @"ZSTutorialBroadcastDidDropSprite";
NSString * const ZSTutorialBroadcastDidDoubleTap = @"ZSTutorialBroadcastDidDoubleTap";
NSString * const ZSTutorialBroadcastDidShowToolbox = @"ZSTutorialBroadcastDidShowToolbox";
NSString * const ZSTutorialBroadcastDidHideToolbox = @"ZSTutorialBroadcastDidHideToolbox";
NSString * const ZSTutorialBroadcastDidTapPaddle = @"ZSTutorialBroadcastDidTapPaddle";

#import <AFNetworking/AFNetworking.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ZSCanvasViewController ()

// Canvas
@property (weak, nonatomic) IBOutlet ZSCanvasView *canvasView;

// Grid Menu
@property (weak, nonatomic) IBOutlet UIView *rendererView;

// Sprites
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;

// Renderer
@property (strong, nonatomic) ZSRendererViewController *rendererViewController;

// Tutorial
@property (strong, nonatomic) ZSTutorial *tutorial;

// Toolbox
@property (strong, nonatomic) ZSToolboxView *toolboxView;
@property (strong, nonatomic) ZSToolboxController *toolboxController;

// Toolbar
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pauseBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *groupBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *toolButton;

@end

@implementation ZSCanvasViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tutorial = [ZSTutorial sharedTutorial];
        _toolboxController = [[ZSToolboxController alloc] init];
    }
    return self;
}

#pragma mark Override Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Test Toolbox
    _toolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
    WeakSelf
    _toolboxView.hidView = ^{
        [weakSelf.tutorial broadcastEvent:ZSTutorialBroadcastDidHideToolbox];
    };
    NSMutableArray *categories = [ZSSpriteLibrary sharedLibrary].categories;
    NSInteger position = 0;
    for (NSMutableArray *category in categories) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        [collectionView registerClass:ZSToolboxCell.class forCellWithReuseIdentifier:@"cellID"];
        collectionView.userInteractionEnabled = YES;
        collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
        collectionView.delegate = _toolboxController;
        collectionView.dataSource = _toolboxController;
        collectionView.tag = position;
        
        [_toolboxView addContentView:collectionView title:categories[position][@"category"]];
        position++;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Import Image" forState:UIControlStateNormal];
    [_toolboxView addButton:button];
    [self.view addSubview:_toolboxView];
    
    // Load the project if it exists.
    if (_project) {
        // Setup delgates, sources and gestures.
        [self setupCanvas];
        [self setupTableDelegatesAndSources];
        
        // Load Sprites.
        [self loadSpritesFromProject];
    }
    
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
    
    // TODO: Figure out the correct place to put this.  The editor may have modified the project
    // so save the project here as well.  This means that the project gets loaded and than saved
    // right away on creation as well.
    [_project write];
    [self.view setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_showTutorial) {
        [self createStageForName:@"setup"];
        [[[ZSEditorViewController alloc] init] createStageForName:nil];
        [self createStageForName:@"paddle2"];
        [_tutorial present];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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

#pragma mark Tutorial

- (void)createStageForName:(NSString *)name {
    WeakSelf
    __block UIView *paddle1 = nil;
    __block UIView *paddle2 = nil;
    __block UIView *ball = nil;
    if ([name isEqualToString:@"setup"]) {
        UICollectionView *collectionView = (UICollectionView*)[_toolboxView viewByIndex:0];
        CGRect ballRect = [collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame;
        ballRect.size.height -= 17;
        CGRect paddleRect = [collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].frame;
        paddleRect.size.height -= 17;
        
        [_tutorial addActionWithText:@"Touch the toolbox icon to open the sprite toolbox."
                            forEvent:ZSTutorialBroadcastDidShowToolbox
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:[_toolbar convertRect:_toolButton.frame toView:self.view]
                               setup:nil
                          completion:nil];
        [_tutorial addActionWithText:@"Drag a paddle sprite onto the lower part of the canvas."
                            forEvent:ZSTutorialBroadcastDidDropSprite
                     allowedGestures:@[UILongPressGestureRecognizer.class]
                        activeRegion:[collectionView convertRect:paddleRect toView:self.view]
                               setup:nil
                          completion:^{
                              paddle1 = [weakSelf.canvasView.subviews lastObject];
                              [weakSelf.tutorial saveObject:paddle1 forKey:@"paddle1"];
                          }];
        [_tutorial addActionWithText:@"Drag another paddle sprite onto the upper part of the canvas."
                            forEvent:ZSTutorialBroadcastDidDropSprite
                     allowedGestures:@[UILongPressGestureRecognizer.class]
                        activeRegion:[collectionView convertRect:paddleRect toView:self.view]
                               setup:nil
                          completion:^{
                              paddle2 = [weakSelf.canvasView.subviews lastObject];
                              [weakSelf.tutorial saveObject:paddle2 forKey:@"paddle2"];
                          }];
        [_tutorial addActionWithText:@"Drag a ball sprite onto the middle of the canvas."
                            forEvent:ZSTutorialBroadcastDidDropSprite
                     allowedGestures:@[UILongPressGestureRecognizer.class]
                        activeRegion:[collectionView convertRect:ballRect toView:self.view]
                               setup:nil
                          completion:^{
                              ball = [weakSelf.canvasView.subviews lastObject];
                              [weakSelf.tutorial saveObject:ball forKey:@"ball"];
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
    }
    if ([name isEqualToString:@"paddle2"]) {
        [_tutorial addActionWithText:@"Touch the lower paddle to bring up the sprite editor."
                            forEvent:ZSTutorialBroadcastDidTapPaddle
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectZero
                               setup:^{
                                   paddle2 = [weakSelf.tutorial getObjectForKey:@"paddle2"];
                                   weakSelf.tutorial.overlayView.activeRegion = paddle2.frame;
                               }
                          completion:nil];
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
            if ([currentSprite[@"id"] isEqualToString:spriteView.spriteJSON[@"id"]]) {
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
    WeakSelf
    
    __block CGPoint offset;
    __block CGPoint currentPoint;
    __block ZSSpriteView *draggedView;
    _toolboxController.longPressBegan = ^(UILongPressGestureRecognizer *panGestureRecognizer) {
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
        [weakSelf.toolboxView hideAnimated:YES];
        [weakSelf.tutorial hideMessage];
    };
    
    _toolboxController.longPressChanged = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
        currentPoint = [longPressGestureRecognizer locationInView:weakSelf.canvasView];
        
        [weakSelf.canvasView moveSprite:draggedView x:currentPoint.x - offset.x y:currentPoint.y - offset.y];
    };
    
    _toolboxController.longPressEnded = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
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
        [weakSelf.toolboxView showAnimated:YES];
        [weakSelf.tutorial broadcastEvent:ZSTutorialBroadcastDidDropSprite];
    };
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
    [_toolboxView showAnimated:YES];
    [_tutorial broadcastEvent:ZSTutorialBroadcastDidShowToolbox];
}

@end
