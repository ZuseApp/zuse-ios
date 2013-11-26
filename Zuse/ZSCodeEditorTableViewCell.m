//
//  ZSCodeEditorTableViewCell.m
//  Zuse
//
//  Created by Vladimir on 11/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCodeEditorTableViewCell.h"

@implementation ZSCodeEditorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCodeLine:(ZSCodeLine *)codeLine
{
    _codeLine = codeLine;
    
    // form text
    NSMutableString *text = [NSMutableString stringWithString:@""];
    for (NSInteger i = 0; i < codeLine.indentation; i++)
    {
        [text appendString:@"       "];
    }
    [text appendString:codeLine.text];
    
    self.textLabel.text = text;
    self.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
}

@end
