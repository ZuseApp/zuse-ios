#import "ZSCodeEditorTableViewCell.h"
#import "ZSCodeStatement.h"
#import "ZSCodeSetStatement.h"

#define ZSCodeEditorTableViewCellIndentation 15 // pixels

@implementation ZSCodeEditorTableViewCell

#pragma mark - UITableViewCell

- (void) layoutSubviews
{
    // Add indentation
    CGRect frame = self.contentView.frame;
    frame.origin.x = self.codeLine.indentation * ZSCodeEditorTableViewCellIndentation;
    frame.size.width -= frame.origin.x;
    self.contentView.frame = frame;
}

- (void) setCodeLine:(ZSCodeLine *)codeLine
{
    _codeLine = codeLine;
    [self updateCellContents];
}

- (void) updateCellContents
{
    @throw @"ZSCodeEditorTableViewCell: updateCellContents should be overridden in subclasses";
}

@end
