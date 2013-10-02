//
//  TCViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "TCCanvasViewController.h"
#import "TCSpriteTableView.h"
#import "TCSprite.h"
#import "TCSpriteView.h"
#import "TCSpriteManager.h"
#import "INInterpreter.h"

@interface TCCanvasViewController ()

@property (nonatomic, strong) TCSpriteManager *spriteManager;
@property (nonatomic, strong) NSArray *templateSprites;
@property (nonatomic, strong) NSArray *canvasSprites;
@property (strong, nonatomic) INInterpreter *interpreter;

@end

@implementation TCCanvasViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:view];
    
    _interpreter = [[INInterpreter alloc] init];
    
    // [_interpreter loadObjects:json[@"objects"]];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
