//
//  ZSCodeEditorOnEventStatementTableViewCell.m
//  Zuse
//
//  Created by Vladimir on 12/1/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCodeEditorOnEventStatementTableViewCell.h"
#import "ZSCodeOnEventStatement.h"

@interface ZSCodeEditorOnEventStatementTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *eventButton;

@end


@implementation ZSCodeEditorOnEventStatementTableViewCell

- (void)setCodeLine:(ZSCodeLine *)codeLine
{
    super.codeLine = codeLine;
    
    ZSCodeOnEventStatement *s = (ZSCodeOnEventStatement *)self.codeLine.statement;
    [self.eventButton setTitle:s.eventName forState:UIControlStateNormal];
}

@end
