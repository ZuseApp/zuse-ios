#import "ZSCanvasViewController.h"
#import "ZSRendererViewController.h"
#import "ZSPhysicsGroupingViewController.h"
#import "ZSSpriteView.h"
#import "ZSEditorViewController.h"
#import "ZSGrid.h"
#import "ZSCanvasView.h"
#import "ZSToolboxController.h"
#import "ZSToolboxView.h"
#import "ZSToolboxCell.h"
#import "ZSSpriteLibrary.h"
#import "ZSTraitEditorViewController.h"
#import "ZSProjectPersistence.h"
#import "ZSCanvasBarButtonItem.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <AFNetworking/AFNetworking.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

typedef NS_ENUM(NSInteger, ZSCanvasInterfaceState) {
    ZSCanvasInterfaceStateNormal,
    ZSCanvasInterfaceStateGroups,
    ZSCanvasInterfaceStateRendererPlaying,
    ZSCanvasInterfaceStateRendererPaused
};

NSString * const ZSTutorialBroadcastDidDropSprite = @"ZSTutorialBroadcastDidDropSprite";
NSString * const ZSTutorialBroadcastDidDoubleTap = @"ZSTutorialBroadcastDidDoubleTap";
NSString * const ZSTutorialBroadcastDidShowToolbox = @"ZSTutorialBroadcastDidShowToolbox";
NSString * const ZSTutorialBroadcastDidHideToolbox = @"ZSTutorialBroadcastDidHideToolbox";
NSString * const ZSTutorialBroadcastDidTapPaddle = @"ZSTutorialBroadcastDidTapPaddle";

typedef NS_ENUM(NSInteger, ZSCanvasTutorialStage) {
    ZSCanvasTutorialSetupStage,
    ZSCanvasTutorialPaddleTwoSetupStage,
    ZSCanvasTutorialBallSetupStage,
    ZSCanvasTutorialGroupSetupStage,
};

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
@property (assign, nonatomic) ZSCanvasTutorialStage tutorialStage;

// Toolbox
@property (strong, nonatomic) ZSToolboxView *toolboxView;
@property (strong, nonatomic) ZSToolboxController *toolboxController;

// Toolbar
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation ZSCanvasViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tutorial = [ZSTutorial sharedTutorial];
        _tutorialStage = ZSCanvasTutorialSetupStage;
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
    
    [self transitionToInterfaceState:ZSCanvasInterfaceStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    
    // TODO: Figure out the correct place to put this.  The editor may have modified the project
    // so save the project here as well.  This means that the project gets loaded and than saved
    // right away on creation as well.
    [self saveProject];
    [self.view setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_tutorial.isActive) {
        [self createTutorialForStage:_tutorialStage];
        [_tutorial presentWithCompletion:^{
            if (_tutorialStage == ZSCanvasTutorialGroupSetupStage) {
                _tutorial.active = NO;
            }
            else {
                _tutorialStage++;
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"renderer"]) {
        ZSRendererViewController *rendererController = (ZSRendererViewController *)segue.destinationViewController;
        rendererController.projectJSON = [_project assembledJSON];
        _rendererViewController = rendererController;
    } else if ([segue.identifier isEqualToString:@"editor"]) {
        ZSEditorViewController *editorController = (ZSEditorViewController *)segue.destinationViewController;
        editorController.spriteObject = ((ZSSpriteView *)sender).spriteJSON;
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

- (void)createTutorialForStage:(ZSCanvasTutorialStage)stage {
    WeakSelf
    __block UIView *paddle1 = nil;
    __block UIView *paddle2 = nil;
    __block UIView *ball = nil;
    if (stage == ZSCanvasTutorialSetupStage) {
        UICollectionView *collectionView = (UICollectionView*)[_toolboxView viewByIndex:0];
        CGRect ballRect = [collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].frame;
        ballRect.size.height -= 17;
        CGRect paddleRect = [collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].frame;
        paddleRect.size.height -= 17;
        
        CGRect settingsButtonRect = ((ZSCanvasBarButtonItem *)_toolbar.items[3]).button.frame;
        
        [_tutorial addActionWithText:@"Touch the toolbox icon to open the sprite toolbox."
                            forEvent:ZSTutorialBroadcastDidShowToolbox
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:[_toolbar convertRect:settingsButtonRect toView:self.view]
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
    if (stage == ZSCanvasTutorialPaddleTwoSetupStage) {
        [_tutorial addActionWithText:@"Touch the upper paddle to bring up the sprite editor."
                            forEvent:ZSTutorialBroadcastDidTapPaddle
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectZero
                               setup:^{
                                   paddle2 = [weakSelf.tutorial getObjectForKey:@"paddle2"];
                                   weakSelf.tutorial.overlayView.activeRegion = paddle2.frame;
                               }
                          completion:nil];
    }
    if (stage == ZSCanvasTutorialBallSetupStage) {
        [_tutorial addActionWithText:@"Touch the ball to bring up the sprite editor."
                            forEvent:ZSTutorialBroadcastDidTapPaddle
                     allowedGestures:@[UITapGestureRecognizer.class]
                        activeRegion:CGRectZero
                               setup:^{
                                   ball = [weakSelf.tutorial getObjectForKey:@"ball"];
                                   weakSelf.tutorial.overlayView.activeRegion = ball.frame;
                               }
                          completion:nil];
    }
}

#pragma mark Project Management

- (void)loadSpritesFromProject {
    NSMutableDictionary *assembledJSON = [_project assembledJSON];
    for (NSMutableDictionary *jsonObject in assembledJSON[@"objects"]) {
        [_canvasView addSpriteFromJSON:jsonObject];
    }
}

- (void)saveProject {
    UIGraphicsBeginImageContext(_canvasView.bounds.size);
    [_canvasView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.project.screenshot = image;
    
    [ZSProjectPersistence writeProject:self.project];
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
        [self saveProject];
    };
    
    _canvasView.spriteRemoved = ^(ZSSpriteView *spriteView) {
        NSMutableArray *objects = [weakSelf.project rawJSON][@"objects"];
        for (NSMutableDictionary *currentSprite in objects) {
            if ([currentSprite[@"id"] isEqualToString:spriteView.spriteJSON[@"id"]]) {
                [objects removeObject:currentSprite];
                break;
            }
        }
        [self saveProject];
    };
    
    _canvasView.spriteModified = ^(ZSSpriteView *spriteView){
        [self saveProject];
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
        [weakSelf saveProject];
        
        // Show the toolbox again.
        [weakSelf.toolboxView showAnimated:YES];
        [weakSelf.tutorial broadcastEvent:ZSTutorialBroadcastDidDropSprite];
    };
}

#pragma mark Main Menu

- (void)playProject {
    [self transitionToInterfaceState:ZSCanvasInterfaceStateRendererPlaying];
    
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

- (void)pauseProject {
    [_rendererViewController stop];
    [self transitionToInterfaceState:ZSCanvasInterfaceStateRendererPaused];
}


- (void)stopProject {
    [self.rendererViewController stop];
    self.rendererView.hidden = YES;
    [self transitionToInterfaceState:ZSCanvasInterfaceStateNormal];
}

- (void)transitionToInterfaceState:(ZSCanvasInterfaceState)state {
    if (state == ZSCanvasInterfaceStateNormal) {
        self.toolbar.items = [self normalToolbarItems];
    } else if (state == ZSCanvasInterfaceStateGroups) {
        self.toolbar.items = [self groupsToolbarItems];
    } else if (state == ZSCanvasInterfaceStateRendererPlaying) {
        self.toolbar.items = [self rendererPlayingToolbarItems];
    } else if (state == ZSCanvasInterfaceStateRendererPaused) {
        self.toolbar.items = [self rendererPausedToolbarItems];
    }
}

- (NSArray *)normalToolbarItems {
    return @[
             [ZSCanvasBarButtonItem playButtonWithHandler:^{
                 [self playProject];
             }],
             [ZSCanvasBarButtonItem flexibleBarButtonItem],
             [ZSCanvasBarButtonItem groupsButtonWithHandler:^{
                 [self modifyGroups];
             }],
             [ZSCanvasBarButtonItem toolboxButtonWithHandler:^{
                 [self showToolbox];
             }],
             [ZSCanvasBarButtonItem shareButtonWithHandler:^{
                 [self shareProject];
             }],
             [ZSCanvasBarButtonItem backButtonWithHandler:^{
                 [self finish];
             }]
             ];
}

- (NSArray *)groupsToolbarItems {
    return @[];
}

- (NSArray *)rendererPlayingToolbarItems {
    return @[
             [ZSCanvasBarButtonItem pauseButtonWithHandler:^{
                 [self pauseProject];
             }],
             [ZSCanvasBarButtonItem stopButtonWithHandler:^{
                 [self stopProject];
             }]
             ];
}

- (NSArray *)rendererPausedToolbarItems {
    return @[
             [ZSCanvasBarButtonItem playButtonWithHandler:^{
                 [self playProject];
             }],
             [ZSCanvasBarButtonItem stopButtonWithHandler:^{
                 [self stopProject];
             }]
             ];
}

- (void)modifyGroups {
    [self performSegueWithIdentifier:@"physicsGroups" sender:self];
}

- (void)finish {
    [self saveProject];
    if (self.didFinish) {
        self.didFinish();
    }
}
- (void)shareProject {
    NSURL *baseURL = [NSURL URLWithString:@"https://zusehub.herokuapp.com/api/v1/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSData *projectData = [NSJSONSerialization dataWithJSONObject:self.project.assembledJSON
     options:NSJSONWritingPrettyPrinted
      error:nil];
    
    NSString *projectString = [[NSString alloc] initWithBytes:projectData.bytes
                                                       length:projectData.length
                                                     encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{
        @"shared_project": @{
            @"title": self.project.title,
            @"raw_code": projectString
        }
    };
                        
    
    // { "url": "..." }
    [manager POST:@"shared_projects"
       parameters:params
          success:^(AFHTTPRequestOperation *operation, NSDictionary *project) {
              NSLog(@"Success! %@", project);
              
              if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                  SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                  [controller setInitialText:[NSString stringWithFormat:@"Check out my game %@ on Zuse!", self.project.title]];
                  [controller addURL:[NSURL URLWithString:project[@"url"]]];
                  [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
                      if (result == SLComposeViewControllerResultCancelled) {
                          NSLog(@"Wooohoo!");
                      }
                      [self dismissViewControllerAnimated:YES completion:^{}];
                  }];
                  [self presentViewController:controller
                                     animated:YES
                                   completion:^{
                                       
                                   }];
              }
          }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Failed! %@", error.localizedDescription);
          }];
}

- (void)showToolbox {
    [_toolboxView showAnimated:YES];
    [_tutorial broadcastEvent:ZSTutorialBroadcastDidShowToolbox];
}

@end
