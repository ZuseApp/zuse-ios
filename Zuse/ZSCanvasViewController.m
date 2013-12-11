#import "ZSCanvasViewController.h"
#import "ZSRendererViewController.h"
#import "ZSSpriteView.h"
#import "ZSProject.h"
#import "ZSMenuController.h"
#import "ZSSpriteController.h"
#import "ZSEditorViewController.h"

@interface ZSCanvasViewController ()

// Gesture Recognizers
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *rightEdgePanRecognizer;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *leftEdgePanRecognizer;

// Menus
@property (weak, nonatomic) IBOutlet UITableView *spriteTable;
@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (strong, nonatomic) ZSSpriteController *spriteController;
@property (strong, nonatomic) ZSMenuController *menuController;
@property (assign, nonatomic, getter = isSpriteTableViewShowing) BOOL spriteTableViewShowing;
@property (assign, nonatomic, getter = isMenuTableViewShowing) BOOL menuTableViewShowing;

// Sprites
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;
@property (strong, nonatomic) ZSProject *project;

@end

@implementation ZSCanvasViewController

#pragma mark Initializers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

#pragma mark Override Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableDelegatesAndSources];
    [self setupScreenEdgeGestures];
    
    _spriteTableViewShowing = NO;
    _menuTableViewShowing = NO;
    
    // Load sprites.
    if (!_projectPath) {
        _projectPath = @"new_project.json";
    }
    
    _project = [ZSProject projectWithFile:_projectPath];
    [self loadSpritesFromProject];
    
    // Bring menus to front.
    [self.view bringSubviewToFront:_menuTable];
    [self.view bringSubviewToFront:_spriteTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];
    [_menuTable deselectRowAtIndexPath:[_menuTable indexPathForSelectedRow] animated:YES];
    _spriteTableViewShowing = NO;
    _menuTableViewShowing = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"renderer"]) {
        ZSRendererViewController *rendererController = (ZSRendererViewController *)segue.destinationViewController;
        rendererController.projectJSON = [_project assembledJSON];
    } else if ([segue.identifier isEqualToString:@"editor"]) {
        ZSEditorViewController *editorController = (ZSEditorViewController *)segue.destinationViewController;
        editorController.spriteObject = ((ZSSpriteView *)sender).spriteJSON;
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
        __weak ZSSpriteView *weakView = view;
        if (imagePath) {
            view.image = [UIImage imageNamed:imagePath];
        } else {
            view.backgroundColor = [UIColor blackColor];
        }
        view.spriteJSON = jsonObject;
        
        view.longTouch = ^(){
            [self performSegueWithIdentifier:@"editor" sender:weakView];
        };
        
        __block CGPoint offset;
        __block CGPoint originPoint;
        __block CGPoint currentPoint;
        view.touchesBegan = ^(UITouch *touch) {
            originPoint = [touch locationInView:self.view];
            offset = [touch locationInView:touch.view];
        };
        
        view.touchesMoved = ^(UITouch *touch) {
            currentPoint = [touch locationInView:self.view];
            
            UIView *touchView = touch.view;
            CGRect frame = touchView.frame;
            
            frame.origin.x = currentPoint.x - offset.x;
            frame.origin.y = currentPoint.y - offset.y;
            
            touchView.frame = frame;
        };
        
        view.touchesEnded = ^(UITouch *touch) {
            UIView *touchView = touch.view;
            
            // Coordinates aren't represeted like they are
            CGFloat x = touchView.frame.origin.x + touchView.frame.size.width;
            CGFloat y = self.view.frame.size.height - touchView.frame.size.width - touchView.frame.origin.y;
            y += touchView.frame.size.height / 2;
            
            variables[@"x"] = @(x);
            variables[@"y"] = @(y);
            variables[@"width"] = @(touchView.frame.size.width);
            variables[@"height"] = @(touchView.frame.size.height);
        };
        [self.view addSubview:view];
    }
    
    WeakSelf
    _menuController.playSelected = ^{
        [weakSelf performSegueWithIdentifier:@"renderer" sender:weakSelf];
    };
}

-(void)setupTableDelegatesAndSources {
    _spriteController = [[ZSSpriteController alloc] init];
    _menuController = [[ZSMenuController alloc] init];
    _spriteTable.delegate = _spriteController;
    _spriteTable.dataSource = _spriteController;
    _menuTable.delegate = _menuController;
    _menuTable.dataSource = _menuController;
}

-(void)setupScreenEdgeGestures {
    _rightEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(canvasPannedRight:)];
    _rightEdgePanRecognizer.edges = UIRectEdgeRight;
    _leftEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(canvasPannedLeft:)];
    _leftEdgePanRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:_rightEdgePanRecognizer];
    [self.view addGestureRecognizer:_leftEdgePanRecognizer];
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

- (IBAction)canvasPannedRight:(id)sender {
    if (_spriteTableViewShowing) return;
    
    UIScreenEdgePanGestureRecognizer *panRecognizer = (UIScreenEdgePanGestureRecognizer *)sender;
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.25 animations:^{
            _spriteTableViewShowing = YES;
            CGRect frame = _spriteTable.frame;
            frame.origin.x -= _spriteTable.frame.size.width;
            _spriteTable.frame = frame;
        }];
    }
}

- (IBAction)canvasPannedLeft:(id)sender {
    if (_menuTableViewShowing) return;
    
    UIScreenEdgePanGestureRecognizer *panRecognizer = (UIScreenEdgePanGestureRecognizer *)sender;
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.25 animations:^{
            _menuTableViewShowing = YES;
            CGRect frame = _menuTable.frame;
            frame.origin.x += _menuTable.frame.size.width;
            _menuTable.frame = frame;
        }];
    }
}

@end
