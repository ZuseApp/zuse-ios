#import "ZSCodeEditorSetStatementTableViewCell.h"
#import "ZSExpressionOptionsTableViewController.h"
#import "ZSCodeSetStatement.h"

#import "ZSPopoverController.h"

@interface ZSCodeEditorSetStatementTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *varNameButton;
@property (weak, nonatomic) IBOutlet UIButton *varValueButton;
@property (strong, nonatomic) ZSCodeSetStatement *statement;

@end

@implementation ZSCodeEditorSetStatementTableViewCell

#pragma mark - ZSCodeEditorTableViewCell

- (void) setCodeLine:(ZSCodeLine *)codeLine
{
    super.codeLine = codeLine;
    self.statement = (ZSCodeSetStatement *)self.codeLine.statement;
}

- (void)updateCellContents
{
    ZSCodeSetStatement *s = (ZSCodeSetStatement *)self.codeLine.statement;
    [self.varNameButton setTitle: s.variableName forState:UIControlStateNormal];
    [self.varValueButton setTitle: s.variableValueStringValue forState:UIControlStateNormal];
}

#pragma mark - ZSCodeEditorSetStatementTableViewCell

- (IBAction)varNameTapped:(id)sender
{
    ZSExpressionOptionsTableViewController *controller = [[ZSExpressionOptionsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    controller.varNames = self.codeLine.statement.availableVarNames;
    
    controller.didSelectValueBlock = ^(id value)
    {
        [self.popover dismissPopoverAnimated:YES];
        // TODO: This is wrong right now, need to change once I have variable
        // listing working correctly.
        //_statement.variableName = [value stringValue];
        
        _statement.variableName = value;
        
        [self updateCellContents];
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
        _statement.variableValue = value;
        [self updateCellContents];
    };
    
    [self presentPopoverWithViewController:controller
                                    inView:sender];
}



@end
