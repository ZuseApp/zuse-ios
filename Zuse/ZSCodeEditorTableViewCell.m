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

- (void)presentPopoverWithViewController:(UIViewController *)controller
                                  inView:(UIView *)view
{
    self.popover = [[ZSPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    [self.popover presentPopoverFromRect:[view bounds]
                                  inView:view
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES];
}


- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    self.popover.delegate = nil;
    self.popover = nil;
}



@end
