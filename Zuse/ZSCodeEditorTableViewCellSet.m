#import "ZSCodeEditorTableViewCellSet.h"
#import "ZSExpressionOptionsTableViewController.h"
#import "ZSCodeStatementSet.h"
#import "ZSCodeEditorVarNameOptionsTableViewController.h"
#import "ZSPopoverController.h"

@interface ZSCodeEditorTableViewCellSet()

@property (weak, nonatomic) IBOutlet UIButton *varNameButton;
@property (weak, nonatomic) IBOutlet UIButton *varValueButton;

@end

@implementation ZSCodeEditorTableViewCellSet

#pragma mark - ZSCodeEditorTableViewCell

- (void)updateCellContents
{
    ZSCodeStatementSet *s = (ZSCodeStatementSet *)self.codeLine.statement;
    [self.varNameButton setTitle: s.variableName forState:UIControlStateNormal];
    [self.varValueButton setTitle: s.variableValueStringValue forState:UIControlStateNormal];
}

#pragma mark - buttons' action handlers

- (IBAction)varNameTapped:(id)sender
{
    ZSCodeEditorVarNameOptionsTableViewController *controller = [[ZSCodeEditorVarNameOptionsTableViewController alloc] init];
    controller.varNames = self.codeLine.statement.availableVarNames;
    controller.didSelectValueBlock = ^(id value)
    {
        ((ZSCodeStatementSet *)self.codeLine.statement).variableName = value;
        [self.popover dismissPopoverAnimated:YES];
        [self.viewController.tableView reloadData];
    };    
    [self presentPopoverWithViewController:controller
                                    inView:sender];
}

- (IBAction)varValueTapped:(id)sender
{
    ZSExpressionOptionsTableViewController *controller = [[ZSExpressionOptionsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    controller.expressionTypeMask = ZSExpressionTypeAny;
    controller.expressionValueMask = ZSExpressionValueAny;
    
    controller.didSelectValueBlock = ^(id value) {
        [self.popover dismissPopoverAnimated:YES];
        ((ZSCodeStatementSet *)self.codeLine.statement).variableValue = value;
        [self updateCellContents];
    };
    
    [self presentPopoverWithViewController:controller
                                    inView:sender];
}



@end
