//
//  ZSCanvasSegue.m
//  Zuse
//
//  Created by Parker Wightman on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSCanvasSegue.h"

@implementation ZSCanvasSegue

- (void)perform {
    UIViewController *sourceViewController = (UIViewController *)[self sourceViewController];
    UIViewController *desinationViewController = (UIViewController *)[self destinationViewController];
    
    [sourceViewController.view addSubview:desinationViewController.view];
}

@end
