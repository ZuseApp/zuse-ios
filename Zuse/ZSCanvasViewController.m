#import "ZSCanvasViewController.h"
#import "ZSRendererViewController.h"
#import "ZSSpriteView.h"
#import "ZSMenuController.h"
#import "ZSSpriteController.h"
#import "ZSEditorViewController.h"
#import "ZSGrid.h"
#import "ZSCanvasView.h"
#import "ZSSettingsViewController.h"
#import "ZSAdjustView.h"

@interface ZSCanvasViewController ()

// Menus
@property (weak, nonatomic) IBOutlet UITableView *spriteTable;
@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (strong, nonatomic) ZSSpriteController *spriteController;
@property (strong, nonatomic) ZSMenuController *menuController;
@property (assign, nonatomic, getter = isSpriteTableViewShowing) BOOL spriteTableViewShowing;
@property (assign, nonatomic, getter = isMenuTableViewShowing) BOOL menuTableViewShowing;

// Grid Menu
@property (weak, nonatomic) IBOutlet ZSAdjustView *adjustMenu;
@property (weak, nonatomic) IBOutlet UILabel *gridWidth;
@property (weak, nonatomic) IBOutlet UILabel *gridHeight;
@property (weak, nonatomic) IBOutlet UIView *gridPanel;
@property (weak, nonatomic) IBOutlet UIView *positionPanel;


// Sprites
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;

// UIMenuController
@property (nonatomic, assign) CGPoint lastTouch;
@property (nonatomic, strong) ZSSpriteView *spriteViewCopy;

@end

@implementation ZSCanvasViewController

#pragma mark Override Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup delgates, sources and gestures.
    [self setupTableDelegatesAndSources];
    [self setupGestures];
    
    _spriteTableViewShowing = NO;
    _menuTableViewShowing = NO;
    
    // Load sprites.
    if (!_project) {
        _project = [[ZSProject alloc] init];
    }
    
    [self loadSpritesFromProject];
    
    // Bring menus to front.
    [self.view bringSubviewToFront:_menuTable];
    [self.view bringSubviewToFront:_spriteTable];
    [self.view bringSubviewToFront:_adjustMenu];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];
    [_menuTable deselectRowAtIndexPath:[_menuTable indexPathForSelectedRow] animated:YES];
    _spriteTableViewShowing = NO;
    _menuTableViewShowing = NO;
    
    // TODO: Figure out the correct place to put this.  The editor may have modified the project
    // so save the project here as well.  This means that the project gets loaded and than saved
    // right away.
    [_project write];
    [self.view setNeedsDisplay];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"renderer"]) {
        ZSRendererViewController *rendererController = (ZSRendererViewController *)segue.destinationViewController;
        rendererController.projectJSON = [_project assembledJSON];
    } else if ([segue.identifier isEqualToString:@"editor"]) {
        ZSEditorViewController *editorController = (ZSEditorViewController *)segue.destinationViewController;
        editorController.spriteObject = ((ZSSpriteView *)sender).spriteJSON;
    } else if  ([segue.identifier isEqualToString:@"settings"]) {
        ZSSettingsViewController *settingsController = (ZSSettingsViewController *)segue.destinationViewController;
        settingsController.grid = ((ZSCanvasView *) self.view).grid;
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
        
        NSDictionary *image = jsonObject[@"image"];
        NSString *imagePath = image[@"path"];
        
        ZSSpriteView *view = [[ZSSpriteView alloc] initWithFrame:frame];
        if (imagePath) {
            view.image = [UIImage imageNamed:imagePath];
        } else {
            view.backgroundColor = [UIColor blackColor];
        }
        view.spriteJSON = jsonObject;
        
        [self setupGesturesForSpriteView:view withProperties:variables];
        [self setupMenuItemsForSpriteView:view];
        [self.view addSubview:view];
    }
}

- (void)setupGesturesForSpriteView:(ZSSpriteView *)view withProperties:(NSMutableDictionary *)properties {
    
    __weak ZSSpriteView *weakView = view;
    view.singleTapped = ^(){
        [self performSegueWithIdentifier:@"editor" sender:weakView];
    };
    
    view.doubleTapped = ^(){
        [self doubleTapRecognized];
    };
    
    view.longPressed = ^(UILongPressGestureRecognizer *longPressedGestureRecognizer){
        
        if (longPressedGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [weakView becomeFirstResponder];
            UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Adjust" action:@selector(showGrid:)];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            menuController.menuItems = [NSArray arrayWithObject:menuItem];
            [menuController setTargetRect:weakView.frame inView:self.view];
            [menuController setMenuVisible:YES animated:YES];
        }
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
        
        self.spriteTableViewShowing = NO;
        self.menuTableViewShowing = NO;
        
        [_project write];
    };
}

- (void)setupMenuItemsForSpriteView:(ZSSpriteView *)view {
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
    copy.spriteJSON = [spriteView.spriteJSON deepMutableCopy];
    copy.spriteJSON[@"id"] = [[NSUUID UUID] UUIDString];
    copy.image = [UIImage imageNamed:copy.spriteJSON[@"image"][@"path"]];
    [self setupGesturesForSpriteView:copy withProperties:copy.spriteJSON[@"properties"]];
    [self setupMenuItemsForSpriteView:copy];
    return copy;
}

- (void)setupTableDelegatesAndSources {
    _spriteController = [[ZSSpriteController alloc] init];
    _menuController = [[ZSMenuController alloc] init];
    _spriteTable.delegate = _spriteController;
    _spriteTable.dataSource = _spriteController;
    _menuTable.delegate = _menuController;
    _menuTable.dataSource = _menuController;
    
    WeakSelf
    __weak ZSProject *weakProject = _project;
    _menuController.playSelected = ^{
        [weakSelf performSegueWithIdentifier:@"renderer" sender:weakSelf];
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
    
    __block CGPoint offset;
    __block CGPoint currentPoint;
    __block ZSSpriteView *draggedView;
    _spriteController.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer, NSDictionary *json) {
        offset = [panGestureRecognizer locationInView:panGestureRecognizer.view];
        currentPoint = [panGestureRecognizer locationInView:weakSelf.view];
        
        CGRect frame = panGestureRecognizer.view.frame;
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        
        draggedView = [[ZSSpriteView alloc] initWithFrame:frame];
        draggedView.image = [UIImage imageNamed:json[@"image"][@"path"]];
        draggedView.contentMode = UIViewContentModeScaleAspectFit;
        [weakSelf.view addSubview:draggedView];
    };
    
    _spriteController.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer, NSDictionary *json) {
        currentPoint = [panGestureRecognizer locationInView:weakSelf.view];
        
        CGRect frame = draggedView.frame;
        frame.origin.x = currentPoint.x - offset.x;
        frame.origin.y = currentPoint.y - offset.y;
        draggedView.frame = frame;
    };
    
    _spriteController.panEnded = ^(UIPanGestureRecognizer *panGestureRecognizer, NSDictionary *json) {
        NSMutableDictionary *newJson = [json deepMutableCopy];
        newJson[@"id"] = [[NSUUID UUID] UUIDString];
        NSMutableDictionary *properties = newJson[@"properties"];
        [weakSelf setupGesturesForSpriteView:draggedView withProperties:properties];
        [weakSelf setupMenuItemsForSpriteView:draggedView];
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
        
        weakSelf.spriteTableViewShowing = NO;
        weakSelf.menuTableViewShowing = NO;
        
        [weakProject write];
    };
}

-(void)setupGestures {
    // Canvas gesture recognizers.
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    [self.view addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
    
    // Sprite Drawer
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideSpriteDrawer)];
    [rightSwipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [_spriteTable addGestureRecognizer:rightSwipeGesture];
    
    // Menu Drawer
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenuDrawer)];
    [leftSwipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_menuTable addGestureRecognizer:leftSwipeGesture];
    
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

- (void)hideSpriteDrawer {
    if (_spriteTableViewShowing) {
        _spriteTableViewShowing = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = _spriteTable.frame;
            frame.origin.x += _spriteTable.frame.size.width;
            _spriteTable.frame = frame;
        }];
    }
}

- (void)hideMenuDrawer {
    if (_menuTableViewShowing) {
        _menuTableViewShowing = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = _menuTable.frame;
            frame.origin.x -= _menuTable.frame.size.width;
            _menuTable.frame = frame;
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    BOOL result = NO;
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        result = YES;
    }
    
    return result;
}

- (IBAction)tableViewPanned:(id)sender {
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)sender;
    
    CGPoint velocity = [panRecognizer velocityInView:_spriteTable];
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        if (ABS(velocity.x) > ABS(velocity.y) && velocity.x > 0) {
            [UIView animateWithDuration:0.25 animations:^{
                _spriteTableViewShowing = NO;
                CGRect frame = _spriteTable.frame;
                frame.origin.x += _spriteTable.frame.size.width;
                _spriteTable.frame = frame;
            }];
        }
    }
}

- (void)doubleTapRecognized {
    if (_spriteTableViewShowing) return;
    
    [UIView animateWithDuration:0.25 animations:^{
        _spriteTableViewShowing = YES;
        CGRect frame = _spriteTable.frame;
        frame.origin.x -= _spriteTable.frame.size.width;
        _spriteTable.frame = frame;
        
        _menuTableViewShowing = YES;
        CGRect menuFrame = _menuTable.frame;
        menuFrame.origin.x += _menuTable.frame.size.width;
        _menuTable.frame = menuFrame;
    }];
}

- (void)longPressRecognized:(id)sender {
    UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer *)sender;
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        [theMenu setTargetRect:CGRectMake(_lastTouch.x, _lastTouch.y, 0, 0) inView:self.view];
        [theMenu setMenuVisible:YES animated:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouch = [[touches anyObject] locationInView:self.view];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_spriteViewCopy && action == @selector(paste:)) {
        return YES;
    }
    if (action == @selector(showGrid:)) {
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
        frame.origin = _lastTouch;
        
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
