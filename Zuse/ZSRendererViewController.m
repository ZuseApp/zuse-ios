//
//  ZSInterpreterViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSRendererViewController.h"
#import "INInterpreter.h"
#import <BlocksKit/BlocksKit.h>

@interface ZSRendererViewController ()

@property (strong, nonatomic) INInterpreter *interpreter;

@end

@implementation ZSRendererViewController

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
	// TODO: Redundant loading of the json since the program object already does this.
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"TestProject" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    _interpreter = [[INInterpreter alloc] init];
    
    [_interpreter loadObjects:json[@"objects"]];
    
    [_interpreter loadMethod:@{
                               @"name": @"ask",
                               @"block":^(NSArray *args, void(^finishedBlock)(id)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hi" message:args[0]];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            __weak UIAlertView *blockAlertView = alertView;
            [alertView addButtonWithTitle:@"OK" handler:^{
                NSString *answer = [blockAlertView textFieldAtIndex:0].text;
                NSLog(@"Answer: %@", answer);
                finishedBlock(@([answer integerValue]));
            }];
            [alertView show];
        });
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
        NSLog(@"Random number: %@", @(rand_num));
        return @(rand_num);
    }
                               }];
    
    [NSThread detachNewThreadSelector:@selector(runInterpreter:) toTarget:self withObject:nil];
}

- (void) runInterpreter:(id)object {
    [_interpreter triggerEvent:@"start"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
