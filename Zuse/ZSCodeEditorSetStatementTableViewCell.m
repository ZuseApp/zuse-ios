#import "ZSCodeEditorSetStatementTableViewCell.h"
#import "ZSExpressionOptionsTableViewController.h"
#import "ZSCodeSetStatement.h"

#import "ZSPopoverController.h"

@interface ZSCodeEditorSetStatementTableViewCell() <WYPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *varNameButton;
@property (weak, nonatomic) IBOutlet UIButton *varValueButton;
@property (strong, nonatomic) ZSCodeSetStatement *statement;
@property (strong, nonatomic) ZSPopoverController *popover;

@end

@implementation ZSCodeEditorSetStatementTableViewCell

#pragma mark - ZSCodeEditorSetStatementTableViewCell

- (void)setCodeLine:(ZSCodeLine *)codeLine
{
    super.codeLine = codeLine;
    _statement = (ZSCodeSetStatement *)self.codeLine.statement;
    [self updateCellContents];
}

- (void)updateCellContents {
    [self.varNameButton setTitle:_statement.variableName forState:UIControlStateNormal];
    [self.varValueButton setTitle:_statement.variableValueStringValue forState:UIControlStateNormal];
}

- (IBAction)varNameTapped:(id)sender {
    ZSExpressionOptionsTableViewController *controller = [[ZSExpressionOptionsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    controller.didSelectValueBlock = ^(id value) {
        [_popover dismissPopoverAnimated:YES];
        // TODO: This is wrong right now, need to change once I have variable
        // listing working correctly.
        _statement.variableName = [value stringValue];
        [self updateCellContents];
    };
    
    [self presentExpressionViewController:controller
                                 fromView:sender];
}

- (IBAction)varValueTapped:(id)sender {
    ZSExpressionOptionsTableViewController *controller = [[ZSExpressionOptionsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    controller.expressionTypeMask = ZSExpressionTypeAny;
    controller.expressionValueMask = ZSExpressionValueAny;
    
    controller.didSelectValueBlock = ^(id value) {
        [_popover dismissPopoverAnimated:YES];
        _statement.variableValue = value;
        [self updateCellContents];
    };
    
    [self presentExpressionViewController:controller
                                 fromView:sender];
}

- (void)presentExpressionViewController:(ZSExpressionOptionsTableViewController *)controller
                               fromView:(UIView *)view{
    
    _popover = [[ZSPopoverController alloc] initWithContentViewController:controller];
    _popover.delegate = self;
    [_popover presentPopoverFromRect:[view bounds]
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
    _popover.delegate = nil;
    _popover = nil;
}

@end
