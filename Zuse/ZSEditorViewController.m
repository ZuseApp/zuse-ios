//
//  ZSEditorViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSEditorViewController.h"
#import "ZSCodeEditorViewController.h"
#import "ZSTraitEditorViewController.h"

@interface ZSEditorViewController ()

@end

@implementation ZSEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ZSCodeEditorViewController *codeController = (ZSCodeEditorViewController *)self.viewControllers[0];
    codeController.spriteObject = self.spriteObject;
    
    ZSTraitEditorViewController *traitController = (ZSTraitEditorViewController *)self.viewControllers[1];
    traitController.traits = self.spriteObject[@"traits"];
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

@end
