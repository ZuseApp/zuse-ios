#import "ZSCodeEditorSetStatementTableViewCell.h"
#import "ZSExpressionOptionsTableViewController.h"
#import "ZSCodeSetStatement.h"
#import "ZSVarNameOptionsTableViewController.h"
#import "ZSPopoverController.h"

@interface ZSCodeEditorSetStatementTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *varNameButton;
@property (weak, nonatomic) IBOutlet UIButton *varValueButton;

@end

@implementation ZSCodeEditorSetStatementTableViewCell

#pragma mark - ZSCodeEditorTableViewCell

- (void)updateCellContents
{
    ZSCodeSetStatement *s = (ZSCodeSetStatement *)self.codeLine.statement;
    [self.varNameButton setTitle: s.variableName forState:UIControlStateNormal];
    [self.varValueButton setTitle: s.variableValueStringValue forState:UIControlStateNormal];
}

#pragma mark - buttons' action handlers

- (IBAction)varNameTapped:(id)sender
{
    ZSVarNameOptionsTableViewController *controller = [[ZSVarNameOptionsTableViewController alloc] init];
    controller.varNames = self.codeLine.statement.availableVarNames;
    controller.didSelectValueBlock = ^(id value)
    {
        ((ZSCodeSetStatement *)self.codeLine.statement).variableName = value;
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
        ((ZSCodeSetStatement *)self.codeLine.statement).variableValue = value;
        [self updateCellContents];
    };
    
    [self presentPopoverWithViewController:controller
                                    inView:sender];
}



@end
