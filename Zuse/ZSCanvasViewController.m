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
#import "TCSpriteManager.h"
#import "TCSprite.h"
#import "TCSpriteView.h"
#import "TCSpriteManager.h"
#import "INInterpreter.h"
#import "ZSProgram.h"
#import <BlocksKit/BlocksKit.h>

@interface ZSCanvasViewController ()
@property (weak, nonatomic) IBOutlet UITableView *spriteTable;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *screenRecognizer;
@property (assign, nonatomic, getter = isTableViewShowing) BOOL tableViewShowing;
@property (nonatomic, strong) TCSpriteManager *spriteManager;
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;
@property (strong, nonatomic) INInterpreter *interpreter;
@property (strong, nonatomic) ZSProgram *program;
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
    _screenRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(canvasPanned:)];
    _screenRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:_screenRecognizer];
    
    _tableViewShowing = NO;
    
#pragma Load Sprites
    _program = [ZSProgram programForResource:@"TestProject" ofType:@"json"];
    for (TCSprite *sprite in _program.sprites) {
    
        // TODO: Consider uncoupling the UI frame component from the sprite.
        TCSpriteView *view = [[TCSpriteView alloc] initWithFrame:sprite.frame];
        __weak TCSpriteView *weakView = view;
        view.sprite = sprite;
        view.backgroundColor = [UIColor blackColor];
        view.touchesBegan = ^(UITouch * touch){
            [self performSegueWithIdentifier:@"editor" sender:weakView];
        };
        [self.view addSubview:view];
    }
    
#pragma Interpreter
    // TODO: Redundant loading of the json since the program object already does this.
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"TestProject" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    _interpreter = [[INInterpreter alloc] init];
    
    [_interpreter loadObjects:json[@"objects"]];
    
    [_interpreter loadMethod:@{
        @"name": @"ask",
        @"block":^id(NSArray *args, NSObject **returnValue) {
            NSThread *thread = [NSThread currentThread];
            dispatch_async(dispatch_get_main_queue(), ^{
                   [UIAlertView showAlertViewWithTitle:@"Question"
                                    message:args[0]
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@[]
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                *returnValue = @"Hi!";
                          }];
            });
        
            return nil;
        }
    }];
    
    [_interpreter loadMethod:@{
        @"name": @"display",
        @"block":^id(NSArray *args) {
            UIAlertView *alertView = [[UIAlertView alloc] init];
            [alertView addButtonWithTitle:@"OK"];
            [alertView setTitle:args[0]];
            [alertView show];
            return nil;
        }
    }];
    
    [_interpreter loadMethod:@{
        @"name": @"random_number",
        @"block":^id(NSArray *args) {
            NSInteger min = [args[0] integerValue];
            NSInteger max = [args[1] integerValue];
            NSUInteger rand_num = arc4random_uniform(max) + min;
            return @(rand_num);
        }
    }];
    
//    [NSThread detachNewThreadSelector:@selector(runInterpreter:) toTarget:self withObject:nil];
}

- (void) runInterpreter:(id)object {
    [_interpreter run];
}

- (void)viewWillAppear:(BOOL)animated {
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, 1.0f, _spriteTable.frame.size.height);
    leftBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                 alpha:1.0f].CGColor;
    [_spriteTable.layer addSublayer:leftBorder];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // Unselect the previous selected cell.
    /* [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];

    if ([segue.identifier isEqualToString:@"playground"]) {
        UINavigationController *controller = (UINavigationController *) segue.destinationViewController;
        ZSPlaygroundViewController *playController = (ZSPlaygroundViewController *) controller.topViewController;
        playController.didFinish = ^{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        };
        _tableViewShowing = NO;
    }*/
    
    if ([segue.identifier isEqualToString:@"editor"]) {
        ZSEditorViewController *editorController = (ZSEditorViewController *)segue.destinationViewController;
        editorController.code = [[(TCSpriteView *)sender sprite] code];
    }
    
    [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];
    _tableViewShowing = NO;
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
                _tableViewShowing = NO;
                CGRect frame = _spriteTable.frame;
                frame.origin.x += 150;
                _spriteTable.frame = frame;
            }];
        }
    }
}

- (IBAction)canvasPanned:(id)sender {
    if (_tableViewShowing) return;
    
    UIScreenEdgePanGestureRecognizer *panRecognizer = (UIScreenEdgePanGestureRecognizer *)sender;
    
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.25 animations:^{
            _tableViewShowing = YES;
            CGRect frame = _spriteTable.frame;
            frame.origin.x -= 150;
            _spriteTable.frame = frame;
        }];
    }
}

#pragma Sprite Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"debug"];
        cell.textLabel.text = @"Playground";
    } else {
        // NSInteger row = indexPath.row - 1;
    }
    return cell;
}

@end
