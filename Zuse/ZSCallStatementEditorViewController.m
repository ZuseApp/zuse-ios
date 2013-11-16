//
//  ZSCallStatementViewController.m
//  Code Editor 2
//
//  Created by Vladimir on 10/24/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//

#import "ZSCallStatementEditorViewController.h"

@interface ZSCallStatementEditorViewController ()

@end

@implementation ZSCallStatementEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.methodName.text = self.codeLine;
}

@end
