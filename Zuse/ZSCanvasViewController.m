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
#import "ZSAdjustView.h"

#import <AFNetworking/AFNetworking.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ZSCanvasViewController ()

// Menus
@property (weak, nonatomic) IBOutlet UITableView *spriteTable;
@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (strong, nonatomic) ZSSpriteController *spriteController;
@property (strong, nonatomic) ZSMenuController *menuController;

// Grid Menu
@property (weak, nonatomic) IBOutlet ZSAdjustView *adjustMenu;
@property (weak, nonatomic) IBOutlet UILabel *gridWidth;
@property (weak, nonatomic) IBOutlet UILabel *gridHeight;
@property (weak, nonatomic) IBOutlet UIView *gridPanel;
@property (weak, nonatomic) IBOutlet UIView *positionPanel;
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

@end

@implementation ZSCanvasViewController

#pragma mark Override Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load the project if it exists.
    if (_project) {
        // Setup delgates, sources and gestures.
        [self setupTableDelegatesAndSources];
        [self setupGestures];
        
        // Load Sprites.
        [self loadSpritesFromProject];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];
    [_menuTable deselectRowAtIndexPath:[_menuTable indexPathForSelectedRow] animated:YES];
    
    // TODO: Figure out the correct place to put this.  The editor may have modified the project
    // so save the project here as well.  This means that the project gets loaded and than saved
    // right away on creation as well.
    [_project write];
    [self.view setNeedsDisplay];
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
        frame.origin.y = self.view.frame.size.height - frame.size.height - frame.origin.y;
        
        ZSSpriteView *view = [[ZSSpriteView alloc] initWithFrame:frame];
        if (![view setContentFromJSON:jsonObject]) {
            // If the sprite isn't marked with a type, ignore it.
            NSLog(@"WARNING: Unkown sprite type.  Skipping adding it to canvas.");
            continue;
        }
        
        [self setupGesturesForSpriteView:view withProperties:variables];
        [self setupEditOptionsForSpriteView:view];
        [self.view addSubview:view];
    }
}

- (void)setupGesturesForSpriteView:(ZSSpriteView *)view withProperties:(NSMutableDictionary *)properties {
    
    WeakSelf
    __weak ZSSpriteView *weakView = view;
    view.singleTapped = ^(){
        [self performSegueWithIdentifier:@"editor" sender:weakView];
    };
    
    view.doubleTapped = ^(){
        [self doubleTapRecognized];
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
        currentPoint = [panGestureRecognizer locationInView:self.view];
        
        UIView *touchView = panGestureRecognizer.view;
        CGRect frame = touchView.frame;
        
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        ZSCanvasView *view = (ZSCanvasView *)self.view;
        if (view.grid.dimensions.width > 1 && view.grid.dimensions.height > 1) {
            frame.origin = [view.grid adjustedPointForPoint:frame.origin];
        }
        
        touchView.frame = frame;
    };
    
    view.panEnded = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        CGRect frame = weakView.frame;
        CGFloat x = frame.origin.x + (frame.size.width / 2);
        CGFloat y = self.view.frame.size.height - frame.size.height - frame.origin.y;
        y += frame.size.height / 2;
        weakView.frame = frame;
        
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        properties[@"width"] = @(frame.size.width);
        properties[@"height"] = @(frame.size.height);
        
        // Bring menus to front.
        [self.view bringSubviewToFront:_menuTable];
        [self.view bringSubviewToFront:_spriteTable];
        
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
    _menuController = [[ZSMenuController alloc] init];
    _spriteTable.delegate = _spriteController;
    _spriteTable.dataSource = _spriteController;
    _menuTable.delegate = _menuController;
    _menuTable.dataSource = _menuController;
    _showRendererAfterMenuClose = NO;
    
    WeakSelf
    __weak ZSProject *weakProject = _project;
    _menuController.playSelected = ^{
        [weakSelf hideDrawersAndPerformAction:^{
            [weakSelf.view bringSubviewToFront:weakSelf.rendererView];
            if (weakSelf.rendererView.hidden) {
                weakSelf.rendererView.hidden = NO;
                weakSelf.rendererViewController.projectJSON = [weakSelf.project assembledJSON];
                [weakSelf.rendererViewController play];
            }
            else {
                [weakSelf.rendererViewController resume];
            }
        }];
    };
    
    _menuController.stopSelected = ^{
        [weakSelf.rendererViewController stop];
        weakSelf.rendererView.hidden = YES;
        [weakSelf hideDrawersAndPerformAction:nil];
    };
    
    _menuController.settingsSelected = ^{
        [weakSelf performSegueWithIdentifier:@"settings" sender:weakSelf];
    };
    
    _menuController.backSelected = ^{
        [weakProject write];
        if (weakSelf.didFinish) {
            weakSelf.didFinish();
        }
    };
    
    _menuController.groupsSelected = ^{
        [weakSelf hideDrawersAndPerformAction:^{
            [weakSelf performSegueWithIdentifier:@"physicsGroups" sender:weakSelf];
        }];
    };
    
    _menuController.shareSelected = ^{
        NSURL *baseURL = [NSURL URLWithString:@"https://zusehub.herokuapp.com/"];
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        [manager POST:@"/projects"
           parameters:@{ @"title": weakSelf.project.title, @"project_json": [weakSelf.project assembledJSON] }
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Success! %@", responseObject);
           }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"Failed! %@", error.localizedDescription);
               if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                   SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                   [controller setInitialText:@"Check out my new game %@ on Zuse!"];
//                   [controller addURL:[NSURL URLWithString:response[@"url"]]];
                   [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
                       if (result == SLComposeViewControllerResultCancelled) {
                           NSLog(@"Wooohoo!");
                       }
                       [weakSelf dismissViewControllerAnimated:YES completion:^{}];
                   }];
                   [weakSelf presentViewController:controller
                                      animated:YES
                                    completion:^{
                                        
                                    }];
               }
           }];
    };
    
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
        currentPoint = [panGestureRecognizer locationInView:weakSelf.view];
        
        originalFrame.origin.x = currentPoint.x - offset.x;
        originalFrame.origin.y = currentPoint.y - offset.y;
        
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        draggedView = [[ZSSpriteView alloc] initWithFrame:frame];
        [draggedView setContentFromJSON:json];
        [weakSelf.view addSubview:draggedView];
       
        CGFloat scale = spriteView.content.frame.size.width / frame.size.width;
        if (scale < 1) {
            draggedView.transform = CGAffineTransformMakeScale(scale, scale);
            [UIView animateWithDuration:0.25f animations:^{
                draggedView.transform = CGAffineTransformIdentity;
            }];
        }
        [weakSelf hideDrawersAndPerformAction:nil];
    };
    
    _spriteController.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        currentPoint = [panGestureRecognizer locationInView:weakSelf.view];
        
        CGRect frame = draggedView.frame;
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        ZSCanvasView *view = (ZSCanvasView *)weakSelf.view;
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
        CGFloat y = weakSelf.view.frame.size.height - draggedView.frame.size.height - draggedView.frame.origin.y;
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
        [weakSelf.view bringSubviewToFront:weakSelf.menuTable];
        [weakSelf.view bringSubviewToFront:weakSelf.spriteTable];
        
        [weakProject write];
        [weakSelf showDrawers];
    };
}

-(void)setupGestures {
    // Canvas gesture recognizers.
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    longPressGesture.delegate = self;
    [self.view addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
    
    // Adjust Menu
    __weak ZSAdjustView *weakAdjust = _adjustMenu;
    __block CGPoint offset;
    __block CGPoint currentPoint;
    _adjustMenu.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        offset = [panGestureRecognizer locationInView:weakAdjust];
    };
    
    _adjustMenu.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        currentPoint = [panGestureRecognizer locationInView:self.view];
        
        CGRect frame = weakAdjust.frame;
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        weakAdjust.frame = frame;
    };
}

- (void)hideDrawersAndPerformAction:(void (^)())action {
    if (!_spriteTable.hidden && !_menuTable.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect menuFrame = _menuTable.frame;
            menuFrame.origin.x -= _menuTable.frame.size.width;
            _menuTable.frame = menuFrame;
            
            if (_rendererView.hidden) {
                CGRect spriteFrame = _spriteTable.frame;
                spriteFrame.origin.x += _spriteTable.frame.size.width;
                _spriteTable.frame = spriteFrame;
            }
            else {
                [_rendererViewController play];
            }
        } completion:^(BOOL finished) {
            self.menuTable.hidden = YES;
            self.spriteTable.hidden = YES;
            if (action) {
                action();
            }
            if (_showRendererAfterMenuClose) {
                [self showGrid:self];
            }
        }];
    }
}

- (void)showDrawers {
    if (_spriteTable.hidden && _menuTable.hidden) {
        // If the adjust menu is showing, hide it.
        _showRendererAfterMenuClose = !_adjustMenu.hidden;
        if (_showRendererAfterMenuClose) {
            [self hideGrid:self];
        }
        
        // Position the drawers off of the screen.
        CGRect menuFrame = _menuTable.frame;
        menuFrame.origin.x = -(_menuTable.frame.size.width);
        _menuTable.frame = menuFrame;
        
        CGRect spriteFrame = _spriteTable.frame;
        spriteFrame.origin.x = self.view.frame.size.width;
        _spriteTable.frame = spriteFrame;
        
        [self.view bringSubviewToFront:_menuTable];
        [self.view bringSubviewToFront:_spriteTable];
        
        // Update the options
        _menuController.rendererRunning = !_rendererView.hidden;
        [_menuTable reloadData];
        
        // Make the drawers visible and animate them in.
        _menuTable.hidden = NO;
        _spriteTable.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect menuFrame = _menuTable.frame;
            menuFrame.origin.x += _menuTable.frame.size.width;
            _menuTable.frame = menuFrame;
            
            if (_rendererView.hidden) {
                CGRect spriteFrame = _spriteTable.frame;
                spriteFrame.origin.x -= _spriteTable.frame.size.width;
                _spriteTable.frame = spriteFrame;
            }
            else {
                [_rendererViewController stop];
            }
        }];
    }
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

- (void)doubleTapRecognized {
    if (_menuTable.hidden && _spriteTable.hidden) {
        [self showDrawers];
    }
    else {
        [self hideDrawersAndPerformAction:nil];
    }
}

- (void)longPressRecognized:(id)sender {
    UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer *)sender;
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [self hideDrawersAndPerformAction:nil];
        if (longPressGesture.view == self.view) {
            // For some reason it doesn't work to make the self.view the first responder.
            [self becomeFirstResponder];
        }
        else {
            [longPressGesture.view becomeFirstResponder];
        }
        _editMenu = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Adjust" action:@selector(showGrid:)];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        menuController.menuItems = [NSArray arrayWithObject:menuItem];
        [_editMenu setTargetRect:CGRectMake(_lastTouch.x, _lastTouch.y, 0, 0) inView:self.view];
        [_editMenu setMenuVisible:YES animated:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouch = [[touches anyObject] locationInView:self.view];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    // If the renderer is showing, don't capture anything.
    if (!_rendererView.hidden || !_menuTable.hidden) {
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
    if (action == @selector(showGrid:) && _adjustMenu.hidden == YES) {
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
        
        ZSCanvasView *view = (ZSCanvasView *)self.view;
        if (view.grid.dimensions.width > 1 && view.grid.dimensions.height > 1) {
            frame.origin = [view.grid adjustedPointForPoint:frame.origin];
        }
        
        CGFloat x = frame.origin.x + (frame.size.width / 2);
        CGFloat y = self.view.frame.size.height - frame.size.height - frame.origin.y;
        y += frame.size.height / 2;
        
        _spriteViewCopy.frame = frame;
        
        NSMutableDictionary *properties = _spriteViewCopy.spriteJSON[@"properties"];
        properties[@"x"] = @(x);
        properties[@"y"] = @(y);
        properties[@"width"] = @(frame.size.width);
        properties[@"height"] = @(frame.size.height);
        
        [self.view addSubview:_spriteViewCopy];
        [[_project rawJSON][@"objects"] addObject:_spriteViewCopy.spriteJSON];
        [_project write];
        
        // Create a new _spriteViewCopy.
        _spriteViewCopy = [self copySpriteView:_spriteViewCopy];
    }
}

#pragma mark Adjustment Menu

- (void)showGrid:(id)sender {
    [self.view bringSubviewToFront:_adjustMenu];
    _adjustMenu.hidden = NO;
}

- (IBAction)hideGrid:(id)sender {
    _adjustMenu.hidden = YES;
}

- (IBAction)showGridPanel:(id)sender {
    _gridPanel.hidden = NO;
    _positionPanel.hidden = YES;
}

- (IBAction)showPositionPanel:(id)sender {
    _positionPanel.hidden = NO;
    _gridPanel.hidden = YES;
}


- (IBAction)gridWidthChanged:(id)sender {
    ZSCanvasView *view = (ZSCanvasView *)self.view;
    UIStepper *slider = (UIStepper*)sender;
    CGSize size = view.grid.dimensions;
    size.width = view.grid.size.width / slider.value;
    view.grid.dimensions = size;
    NSInteger value = slider.value;
    _gridWidth.text = [NSString stringWithFormat:@"%li", (long)value];
    [view setNeedsDisplay];
}

- (IBAction)gridHeightChanged:(id)sender {
    ZSCanvasView *view = (ZSCanvasView *)self.view;
    UIStepper *slider = (UIStepper*)sender;
    CGSize size = view.grid.dimensions;
    size.height = view.grid.size.height / slider.value;
    view.grid.dimensions = size;
    NSInteger value = slider.value;
    _gridHeight.text = [NSString stringWithFormat:@"%li", (long)value];
    [view setNeedsDisplay];
}

@end
