//
//  ZSCanvasViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/1/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCanvasViewController.h"
#import "ZSPlaygroundViewController.h"
#import "TCSpriteManager.h"
#import "TCSprite.h"
#import "TCSpriteView.h"
#import "TCSpriteManager.h"
#import "INInterpreter.h"

@interface ZSCanvasViewController ()
@property (weak, nonatomic) IBOutlet UITableView *spriteTable;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *screenRecognizer;
@property (assign, nonatomic, getter = isTableViewShowing) BOOL tableViewShowing;
@property (nonatomic, strong) TCSpriteManager *spriteManager;
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;
@property (strong, nonatomic) INInterpreter *interpreter;
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
    // _screenRecognizer.delegate = self;
    _screenRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:_screenRecognizer];
    
    _tableViewShowing = YES;
    
#pragma Interpreter
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"TestProject" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    // NSLog(@"%@", json);
    NSDictionary *jsonObject = [json[@"objects"] firstObject];
    NSDictionary *variables = jsonObject[@"variables"];
    CGRect frame = CGRectZero;
    
    frame.origin.x = [variables[@"x"] floatValue];
    frame.origin.y = [variables[@"y"] floatValue];
    frame.size.width = [variables[@"width"] floatValue];
    frame.size.height = [variables[@"height"] floatValue];
    
    TCSpriteView *view = [[TCSpriteView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blackColor];
    view.touchesBegan = ^(UITouch * touch){
        NSLog(@"Touched");
    };
    [self.view addSubview:view];
    
    _interpreter = [[INInterpreter alloc] init];
    
    [_interpreter loadObjects:json[@"objects"]];
    
    [_interpreter loadMethod:@{
        @"name": @"ask",
        @"block":^id(NSArray *args) {
            return @8;
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
    
    [_interpreter run];
}

- (void)viewDidAppear:(BOOL)animated {
    CALayer *leftBorder = [CALayer layer];
    leftBorder.frame = CGRectMake(0.0f, 0.0f, 1.0f, _spriteTable.frame.size.height);
    leftBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                 alpha:1.0f].CGColor;
    [_spriteTable.layer addSublayer:leftBorder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // Unselect the previous selected cell.
    [_spriteTable deselectRowAtIndexPath:[_spriteTable indexPathForSelectedRow] animated:YES];

    if ([segue.identifier isEqualToString:@"playground"]) {
        UINavigationController *controller = (UINavigationController *) segue.destinationViewController;
        ZSPlaygroundViewController *playController = (ZSPlaygroundViewController *) controller.topViewController;
        playController.didFinish = ^{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        };
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
