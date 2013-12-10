#import "ZSCodeEditorTableViewCellSet.h"
#import "ZSCodeStatementSet.h"
#import "ZSCodeEditorPopoverExpressionOptionsDataSource.h"
#import "ZSCodeEditorPopoverVarNameOptionsDataSource.h"

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
<<<<<<< HEAD
    ZSCodeEditorPopoverVarNameOptionsDataSource *s = [[ZSCodeEditorPopoverVarNameOptionsDataSource alloc]initWithAvailableVarNames:self.codeLine.statement.availableVarNames];
    ZSCodeEditorPopoverTableViewController *c = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain dataSource:s];
    
    c.didSelectRowBlock = ^(NSInteger row)
    {
        ((ZSCodeStatementSet *)self.codeLine.statement).variableName = self.codeLine.statement.availableVarNames[row];
=======
    ZSCodeEditorVarNameOptionsTableViewController *controller = [[ZSCodeEditorVarNameOptionsTableViewController alloc] init];
    controller.varNames = self.codeLine.statement.availableVarNames;
    controller.didSelectValueBlock = ^(id value) {
        ((ZSCodeStatementSet *)self.codeLine.statement).variableName = value;
>>>>>>> 82bec66dd9d6c7be0487d4c1ea2cb3c4e2174bf4
        [self.popover dismissPopoverAnimated:YES];
        [self.viewController.tableView reloadData];
    };    
    [self presentPopoverWithViewController:c
                                    inView:sender];
}

- (IBAction)varValueTapped:(id)sender
{
    ZSCodeEditorPopoverExpressionOptionsDataSource *s = [[ZSCodeEditorPopoverExpressionOptionsDataSource alloc]init];
    ZSCodeEditorPopoverTableViewController *c
    = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain
                                                        dataSource:s];
    c.didSelectRowBlock = ^(NSInteger row)
    {
        [self.popover dismissPopoverAnimated:YES];
        ((ZSCodeStatementSet *)self.codeLine.statement).variableValue = [@(row) stringValue];
        [self updateCellContents];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}



@end