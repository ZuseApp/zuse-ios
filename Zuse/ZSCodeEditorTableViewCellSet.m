#import "ZSCodeEditorTableViewCellSet.h"
#import "ZSCodeStatementSet.h"
#import "ZSCodeEditorPopoverExpressionOptionsDataSource.h"
#import "ZSCodeEditorPopoverVarNameOptionsDataSource.h"
#import <MTBlockAlertView/MTBlockAlertView.h>

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
    ZSCodeEditorPopoverVarNameOptionsDataSource *s = [[ZSCodeEditorPopoverVarNameOptionsDataSource alloc]initWithAvailableVarNames:self.codeLine.statement.availableVarNames];
    ZSCodeEditorPopoverTableViewController *c = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain dataSource:s];
    
   /*
    TODO: The cell should not be responsible for knowing the order
    of rows, it should just be handed a value. Disadvantages before I forget:
  
    1. If the row order ever changes, then we have to change code here instead of
       in the data source. The data source is the one generating the row order,
       it should also be responsible for mapping it to the correct values.
  
    2. This popover may be used in multiple places, which means that
       all this MTBlockAlertView business, checking row order, coercing values, etc.,
       would have to be duplicated in every place we use this, instead of just
       once in the data source.
  
    3. The expression popover, in particular, doesn't always produce strings. If they
       select a number, then it should be converted from NSString -> NSNumber. Again, logic
       that belongs in the data source and, as it currently stands, would require duplication
       everywhere we use the expression popover.
  
    4. This works ok if selecting a row always produced a value, but sometimes it's a multi-step
       process. Selecting a row pushes on a new table view, then pops up an alert view, etc. At this
       point in time, you no longer have a clear reference to the initial view controller in order to
       push a new one on, and even if there was, it's just more code duplication.
    */
    c.didSelectRowBlock = ^(NSInteger row)
    {
        
        if (row == 0) {
            [MTBlockAlertView showWithTitle:@"New Property"
                                    message:@"Enter a property name."
                          cancelButtonTitle:@"Cancel"
                           otherButtonTitle:@"OK"
                             alertViewStyle:UIAlertViewStylePlainTextInput
                            completionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                ((ZSCodeStatementSet *)self.codeLine.statement).variableName = [alertView textFieldAtIndex:0].text;
                                [self.popover dismissPopoverAnimated:YES];
                                [self.viewController.tableView reloadData];
                            }];
        } else {
            
            NSString *varName = self.codeLine.statement.availableVarNames[row - 1];
            ((ZSCodeStatementSet *)self.codeLine.statement).variableName = varName;
            [self.viewController.tableView reloadData];
        }
        [self.popover dismissPopoverAnimated:YES];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}

- (IBAction)varValueTapped:(id)sender
{
    ZSCodeEditorPopoverExpressionOptionsDataSource *s = [[ZSCodeEditorPopoverExpressionOptionsDataSource alloc]initWithAvailableVarNames:self.codeLine.statement.availableVarNames
                                                         StatementType:ZSCodeStatementTypeSet];
    ZSCodeEditorPopoverTableViewController *c
    = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain
                                                        dataSource:s];
    c.didSelectRowBlock = ^(NSInteger row)
    {
        ZSCodeStatementSet *statement = ((ZSCodeStatementSet *)self.codeLine.statement);
        
        // If new value
        if (row == 0)
        {
            MTBlockAlertView *alertView = [[MTBlockAlertView alloc] initWithTitle:@"New number"
                                                                          message:@"Enter a number"
                                                                completionHanlder:^(UIAlertView *alertView,
                                                                                    NSInteger buttonIndex) {
                                                                    ((ZSCodeStatementSet *)self.codeLine.statement).variableValue = @([[alertView textFieldAtIndex:0].text integerValue]);
                                                                    [self.viewController.tableView reloadData];
                                                                }
                                                                cancelButtonTitle:@"Cancel"
                                                                otherButtonTitles:@"OK", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
            [alertView show];
        }
        // existing variable
        else
        {
            NSString *varName = self.codeLine.statement.availableVarNames[row - 1];
            statement.variableValue = @{ @"get": varName };
            [self.viewController.tableView reloadData];
        }
        [self.popover dismissPopoverAnimated:YES];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}



@end
