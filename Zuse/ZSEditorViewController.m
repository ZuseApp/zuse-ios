//
//  ZSEditorViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSEditorViewController.h"
#import "ZSCodeEditorViewController.h"

@interface ZSEditorViewController ()

@end

@implementation ZSEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ZSCodeEditorViewController *codeController = (ZSCodeEditorViewController *)self.viewControllers[0];
    [codeController processJSON:self.spriteObject];
	// Do any additional setup after loading the view.
}

@end
