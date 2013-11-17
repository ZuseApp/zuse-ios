//
//  ZSCanvasViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/1/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCanvasViewController.h"
#import "ZSPlaygroundViewController.h"
#import "ZSEditorViewController.h"
#import "TCSprite.h"
#import "TCSpriteView.h"
#import "ZSProgram.h"
#import "ZSMenuController.h"
#import "ZSSpriteController.h"

@interface ZSCanvasViewController ()
@property (weak, nonatomic) IBOutlet UITableView *spriteTable;
@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *rightEdgePanRecognizer;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *leftEdgePanRecognizer;
@property (assign, nonatomic, getter = isSpriteTableViewShowing) BOOL spriteTableViewShowing;
@property (assign, nonatomic, getter = isMenuTableViewShowing) BOOL menuTableViewShowing;
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;
@property (strong, nonatomic) ZSProgram *program;
@property (strong, nonatomic) ZSSpriteController *spriteController;
@property (strong, nonatomic) ZSMenuController *menuController;
@end

@implementation ZSCanvasViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rightEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(canvasPannedRight:)];
    _rightEdgePanRecognizer.edges = UIRectEdgeRight;
    _leftEdgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(canvasPannedLeft:)];
    _leftEdgePanRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:_rightEdgePanRecognizer];
    [self.view addGestureRecognizer:_leftEdgePanRecognizer];
    
    _spriteTableViewShowing = NO;
    _menuTableViewShowing = NO;
    
#pragma Set up Table delegates and data sources.
    _spriteController = [[ZSSpriteController alloc] init];
    _menuController = [[ZSMenuController alloc] init];
    _spriteTable.delegate = _spriteController;
    _spriteTable.dataSource = _spriteController;
    _menuTable.delegate = _menuController;
    _menuTable.dataSource = _menuController;
    
#pragma Load Sprites
    _program = [ZSProgram programForResource:@"pong" ofType:@"json"];
    for (TCSprite *sprite in _program.sprites) {
        
        // TODO: Consider uncoupling the UI frame component from the sprite.
        TCSpriteView *view = [[TCSpriteView alloc] initWithFrame:sprite.frame];
        __weak TCSpriteView *weakView = view;
        view.sprite = sprite;
        view.backgroundColor = [UIColor blackColor];
        view.longTouch = ^(){
            [self performSegueWithIdentifier:@"editor" sender:weakView];
        };
        [self.view addSubview:view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, 1.0f, _spriteTable.frame.size.height);
    leftBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [_spriteTable.layer addSublayer:leftBorder];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.frame = CGRectMake(_menuTable.frame.size.width, 0.0f, 1.0f, _menuTable.frame.size.height);
    rightBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [_menuTable.layer addSublayer:rightBorder];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"editor"]) {
        ZSEditorViewController *editorController = (ZSEditorViewController *)segue.destinationViewController;
        editorController.code = [[(TCSpriteView *)sender sprite] code];
    }
    
    [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];
    _spriteTableViewShowing = NO;
    _menuTableViewShowing = NO;
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
                frame.origin.x += 150;
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
            frame.origin.x -= 150;
            _spriteTable.frame = frame;
        }];
    }
}

- (IBAction)canvasPannedLeft:(id)sender {
    // if (_menuTableViewShowing) return;
    
    UIScreenEdgePanGestureRecognizer *panRecognizer = (UIScreenEdgePanGestureRecognizer *)sender;
    
    [self.view bringSubviewToFront:_menuTable];
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.25 animations:^{
            _menuTableViewShowing = YES;
            CGRect frame = _menuTable.frame;
            frame.origin.x += 150;
            _menuTable.frame = frame;
        }];
    }
}

@end
