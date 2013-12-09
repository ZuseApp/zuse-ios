//
//  ZSSetStatementEditorViewController.m
//  Code Editor 2
//
//  Created by Vladimir on 10/21/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//
#import "ZSSetStatementEditorViewController.h"
#import "ZSCodeStatementSet.h"

@interface ZSSetStatementEditorViewController()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@end

@implementation ZSSetStatementEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ZSCodeStatementSet *statement = (ZSCodeStatementSet *)self.codeLine.statement;
    
    self.nameTextField.text = statement.variableName;
    self.valueTextField.text = statement.variableValueStringValue;
}

@end
