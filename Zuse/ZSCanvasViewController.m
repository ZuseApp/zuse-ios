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
@property (nonatomic, assign) BOOL showRendererAfterMenuClose;

// Sprites
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;

// UIMenuController
@property (nonatomic, strong) UIMenuController *editMenu;
@property (nonatomic, assign) CGPoint lastTouch;
@property (nonatomic, strong) ZSSpriteView *spriteViewCopy;

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
    _tutorial = [[ZSTutorial alloc] init];
    
    // Load the project if it exists.
    if (_project) {
        // Setup delgates, sources and gestures.
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
        [_tutorial addActionWithText:@"Touch here to open the toolbox." forEvent:ZSTutorialBroadcastDidShowToolbox activeRegion:[_toolbar convertRect:_toolButton.frame toView:self.view] setup:nil completion:nil];
        [_tutorial addActionWithText:@"Drag a paddle sprite onto the lower part of the canvas." forEvent:ZSTutorialBroadcastDidDropSprite activeRegion:[_spriteTable convertRect:paddleRect toView:self.view] setup:nil completion:^{
            paddle1 = [weakSelf.canvasView.subviews lastObject];
        }];
        [_tutorial addActionWithText:@"Drag another paddle sprite onto the upper part of the canvas." forEvent:ZSTutorialBroadcastDidDropSprite activeRegion:[_spriteTable convertRect:paddleRect toView:self.view] setup:nil completion:^{
            paddle2 = [weakSelf.canvasView.subviews lastObject];
        }];
        [_tutorial addActionWithText:@"Drag a ball sprite onto the middle of the canvas." forEvent:ZSTutorialBroadcastDidDropSprite activeRegion:[_spriteTable convertRect:ballRect toView:self.view] setup:nil completion:^{
            ball = [weakSelf.canvasView.subviews lastObject];
        }];
        [_tutorial addActionWithText:@"Touch anywhere outside of the toolbox to close it." forEvent:ZSTutorialBroadcastDidHideToolbox activeRegion:self.view.frame setup:^{
            weakSelf.tutorial.toolTipOverrideView = weakSelf.toolboxView;
        } completion:^{
            weakSelf.tutorial.toolTipOverrideView = nil;
        }];
        [_tutorial addActionWithText:@"Touch the lower paddle to bring up the sprite editor." forEvent:ZSTutorialBroadcastDidTapPaddle activeRegion:CGRectZero setup:^{
            weakSelf.tutorial.overlayView.activeRegion = paddle1.frame;
        } completion:nil];
        [_tutorial present];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Hide the UIMenuController if it exists and is showing.
    if (_editMenu) {
        [_editMenu setMenuVisible:NO animated:YES];
    }
    
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

#pragma mark Private Methods

// starting with verb indicates not returning anything
// method name indicates passed parameters
-(void)loadSpritesFromProject {
    NSMutableDictionary *assembledJSON = [_project assembledJSON];
    for (NSMutableDictionary *jsonObject in assembledJSON[@"objects"]) {
        NSMutableDictionary *variables = jsonObject[@"properties"];
        
        CGRect frame = CGRectZero;
        frame.origin.x = [variables[@"x"] floatValue];
        frame.origin.y = [variables[@"y"] floatValue];
        frame.size.width = [variables[@"width"] floatValue];
        frame.size.height = [variables[@"height"] floatValue];
        
        // Coordinates in the project are stored in the center of the sprite and the canvas origin is
        // in the bottom left corner, so adjust for that.
        frame.origin.x -= frame.size.width / 2;
        frame.origin.y -= frame.size.height / 2;
        frame.origin.y = _canvasView.frame.size.height - frame.size.height - frame.origin.y;
        
        ZSSpriteView *view = [[ZSSpriteView alloc] initWithFrame:frame];
        if (![view setContentFromJSON:jsonObject]) {
            // If the sprite isn't marked with a type, ignore it.
            NSLog(@"WARNING: Unkown sprite type.  Skipping adding it to canvas.");
            continue;
        }
        
        [self setupGesturesForSpriteView:view withProperties:variables];
        [self setupEditOptionsForSpriteView:view];
        [_canvasView addSubview:view];
    }
}

- (void)setupGesturesForSpriteView:(ZSSpriteView *)view withProperties:(NSMutableDictionary *)properties {
    
    WeakSelf
    __weak ZSSpriteView *weakView = view;
    view.singleTapped = ^(){
        [_tutorial broadcastEvent:ZSTutorialBroadcastDidTapPaddle];
        [self performSegueWithIdentifier:@"editor" sender:weakView];
    };
    
    view.longPressed = ^(UILongPressGestureRecognizer *longPressedGestureRecognizer){
        [weakSelf longPressRecognized:longPressedGestureRecognizer];
    };
    
    __block CGPoint offset;
    __block CGPoint currentPoint;
    view.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        offset = [panGestureRecognizer locationInView:panGestureRecognizer.view];
    };
    
    view.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        currentPoint = [panGestureRecognizer locationInView:self.canvasView];
        
        UIView *touchView = panGestureRecognizer.view;
        CGRect frame = touchView.frame;
        
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        if (_canvasView.grid.dimensions.width > 1 && _canvasView.grid.dimensions.height > 1) {
            frame.origin = [_canvasView.grid adjustedPointForPoint:frame.origin];
        }
        
        touchView.frame = frame;
    };
    
    view.panEnded = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        CGRect frame = weakView.frame;
        CGFloat x = frame.origin.x + (frame.size.width / 2);
        CGFloat y = _canvasView.frame.size.height - frame.size.height - frame.origin.y;
        y += frame.size.height / 2;
        weakView.frame = frame;
        
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        properties[@"width"] = @(frame.size.width);
        properties[@"height"] = @(frame.size.height);
        
        // Bring menus to front.
        [_canvasView bringSubviewToFront:_spriteTable];
        
        [_project write];
    };
}

- (void)setupEditOptionsForSpriteView:(ZSSpriteView *)view {
    WeakSelf
    __weak ZSProject *weakProject = _project;
    __weak ZSSpriteView *weakView = view;
    view.delete = ^(ZSSpriteView *sprite) {
        [sprite removeFromSuperview];
        NSMutableArray *objects = [weakSelf.project rawJSON][@"objects"];
        for (NSMutableDictionary *currentSprite in objects) {
            if (currentSprite[@"id"] == sprite.spriteJSON[@"id"]) {
                [objects removeObject:currentSprite];
                break;
            }
        }
        [weakProject write];
    };
    
    view.copy = ^(ZSSpriteView *sprite) {
        _spriteViewCopy = [weakSelf copySpriteView:sprite];
    };
    
    view.cut = ^(ZSSpriteView *sprite) {
        _spriteViewCopy = [weakSelf copySpriteView:sprite];
        [sprite removeFromSuperview];
        NSMutableArray *objects = [weakSelf.project rawJSON][@"objects"];
        for (NSMutableDictionary *currentSprite in objects) {
            if (currentSprite[@"id"] == sprite.spriteJSON[@"id"]) {
                [objects removeObject:currentSprite];
                break;
            }
        }
        [weakProject write];
    };
    
    view.paste = ^(ZSSpriteView *sprite) {
        [weakSelf paste:weakView];
    };
}

- (ZSSpriteView *)copySpriteView:(ZSSpriteView *)spriteView {
    ZSSpriteView *copy = [[ZSSpriteView alloc] initWithFrame:spriteView.frame];
    NSMutableDictionary *json = [spriteView.spriteJSON deepMutableCopy];
    json[@"id"] = [[NSUUID UUID] UUIDString];
    [copy setContentFromJSON:json];
    [self setupGesturesForSpriteView:copy withProperties:copy.spriteJSON[@"properties"]];
    [self setupEditOptionsForSpriteView:copy];
    return copy;
}

- (void)setupTableDelegatesAndSources {
    _spriteController = [[ZSSpriteController alloc] init];
    _spriteTable.delegate = _spriteController;
    _spriteTable.dataSource = _spriteController;
    _showRendererAfterMenuClose = NO;
    
    WeakSelf
    __block CGPoint offset;
    __block CGPoint currentPoint;
    __block ZSSpriteView *draggedView;
    _spriteController.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer) {
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
    
    _spriteController.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        currentPoint = [panGestureRecognizer locationInView:weakSelf.canvasView];
        
        CGRect frame = draggedView.frame;
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        ZSCanvasView *view = (ZSCanvasView *)weakSelf.canvasView;
        if (view.grid.dimensions.width > 1 && view.grid.dimensions.height > 1) {
            frame.origin = [view.grid adjustedPointForPoint:frame.origin];
        }
        
        draggedView.frame = frame;
    };
    
    _spriteController.panEnded = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        NSMutableDictionary *json = draggedView.spriteJSON;
        
        NSMutableDictionary *newJson = [json deepMutableCopy];
        newJson[@"id"] = [[NSUUID UUID] UUIDString];
        NSMutableDictionary *properties = newJson[@"properties"];
        [weakSelf setupGesturesForSpriteView:draggedView withProperties:properties];
        [weakSelf setupEditOptionsForSpriteView:draggedView];
        [[weakSelf.project rawJSON][@"objects"] addObject:newJson];
        
        CGFloat x = draggedView.frame.origin.x + (draggedView.frame.size.width / 2);
        CGFloat y = weakSelf.canvasView.frame.size.height - draggedView.frame.size.height - draggedView.frame.origin.y;
        y += draggedView.frame.size.height / 2;
        
        CGPoint center = draggedView.center;
        CGRect frame = draggedView.frame;
        frame.size.width = [properties[@"width"] floatValue];
        frame.size.height = [properties[@"height"] floatValue];
        draggedView.frame = frame;
        draggedView.center = center;
        draggedView.spriteJSON = newJson;
        
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        
        // Bring menus to front.
        [weakSelf.view bringSubviewToFront:weakSelf.spriteTable];
        [weakSelf.project write];
        
        // Show the toolbox again.
        [weakSelf showToolbox];
        [weakSelf.tutorial broadcastEvent:ZSTutorialBroadcastDidDropSprite];
    };
}

-(void)setupGestures {
    // Canvas gesture recognizers.
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    longPressGesture.delegate = self;
    [_canvasView addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
    singleTapGesture.numberOfTapsRequired = 1;
    [_canvasView addGestureRecognizer:singleTapGesture];
    
    // Blurview gesture recognizers.
    singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
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

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && !_rendererView.hidden) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    BOOL result = NO;
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        result = YES;
    }
    
    return result;
}

- (void)singleTapRecognized {
    if (!_toolboxView.hidden) {
        [self hideToolbox];
    }
}

- (void)longPressRecognized:(id)sender {
    UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer *)sender;
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [longPressGesture.view becomeFirstResponder];
        _editMenu = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Adjust" action:@selector(showAdjustMenu:)];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        menuController.menuItems = [NSArray arrayWithObject:menuItem];
        [_editMenu setTargetRect:CGRectMake(_lastTouch.x, _lastTouch.y, 0, 0) inView:_canvasView];
        [_editMenu setMenuVisible:YES animated:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouch = [[touches anyObject] locationInView:_canvasView];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    // If the renderer is showing, don't capture anything.
    if (!_rendererView.hidden) {
        return NO;
    }
    
    // Check to see if the action is being performed on top of the adjust menu.
    CGRect frame = _adjustMenu.frame;
    if ((_adjustMenu.hidden == NO) && _lastTouch.x >= frame.origin.x && _lastTouch.x <= frame.origin.x + frame.size.width && _lastTouch.y >= frame.origin.y && _lastTouch.y <= frame.origin.y + frame.size.height) {
        return NO;
    }
    if (_spriteViewCopy && action == @selector(paste:)) {
        return YES;
    }
    if (action == @selector(showAdjustMenu:) && _adjustMenu.hidden == YES) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)paste:(id)sender {
    if (_spriteViewCopy) {
        CGRect frame = _spriteViewCopy.frame;
        frame.origin = CGPointMake(_lastTouch.x - frame.size.width / 2, _lastTouch.y - frame.size.height / 2);
        
        if (_canvasView.grid.dimensions.width > 1 && _canvasView.grid.dimensions.height > 1) {
            frame.origin = [_canvasView.grid adjustedPointForPoint:frame.origin];
        }
        
        CGFloat x = frame.origin.x + (frame.size.width / 2);
        CGFloat y = _canvasView.frame.size.height - frame.size.height - frame.origin.y;
        y += frame.size.height / 2;
        
        _spriteViewCopy.frame = frame;
        
        NSMutableDictionary *properties = _spriteViewCopy.spriteJSON[@"properties"];
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        properties[@"width"] = @(frame.size.width);
        properties[@"height"] = @(frame.size.height);
        
        [_canvasView addSubview:_spriteViewCopy];
        [[_project rawJSON][@"objects"] addObject:_spriteViewCopy.spriteJSON];
        [_project write];
        
        // Create a new _spriteViewCopy.
        _spriteViewCopy = [self copySpriteView:_spriteViewCopy];
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
        self.rendererView.hidden = NO;
        self.rendererViewController.projectJSON = [self.project assembledJSON];
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
