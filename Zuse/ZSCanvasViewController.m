#import "ZSCanvasViewController.h"
#import "ZSPlaygroundViewController.h"
#import "ZSRendererViewController.h"
#import "TCSprite.h"
#import "TCSpriteView.h"
#import "ZSProgram.h"
#import "ZSMenuController.h"
#import "ZSSpriteController.h"

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
@property (strong, nonatomic) ZSProgram *program;

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
    _program = [ZSProgram programWithFile:@"pong.json"];
    [self loadSpritesFromProgram];
    
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
        [self saveProject];
        ZSRendererViewController *rendererController = (ZSRendererViewController *)segue.destinationViewController;
        rendererController.projectJSON = [_program projectJSON];
    }
}

#pragma mark Private Methods

// starting with verb indicates not returning anything
// method name indicates passed parameters
-(void)loadSpritesFromProgram {
    for (TCSprite *sprite in _program.sprites) {
        
        TCSpriteView *view = [[TCSpriteView alloc] initWithFrame:sprite.frame];
        // __weak TCSpriteView *weakView = view;
        view.sprite = sprite;
        if (sprite.imagePath) {
            view.image = [UIImage imageNamed:sprite.imagePath];
        } else {
            view.backgroundColor = [UIColor blackColor];
        }
        view.longTouch = ^(){
            // [self performSegueWithIdentifier:@"editor" sender:weakView];
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
            sprite.frame = frame;
            
        };
        
        view.touchesEnded = ^(UITouch *touch) {
            
        };
        [self.view addSubview:view];
    }
    
    WeakSelf
    _menuController.playSelected = ^{
        [weakSelf performSegueWithIdentifier:@"renderer" sender:weakSelf];
    };
}

-(void)saveProject {
    [_program writeToFile:@"pong.json"];
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
