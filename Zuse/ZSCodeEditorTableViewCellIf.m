#import "ZSCodeEditorTableViewCellIf.h"
#import "ZSCodeStatementIf.h"
#import "ZSCodeEditorPopoverExpressionOptionsDataSource.h"

@interface ZSCodeEditorTableViewCellIf()

@property (weak, nonatomic) IBOutlet UIButton *exp1;
@property (weak, nonatomic) IBOutlet UIButton *exp2;
@property (weak, nonatomic) IBOutlet UIButton *sign;

@property (strong, nonatomic) NSArray *signs;

@end

@implementation ZSCodeEditorTableViewCellIf

- (void)updateCellContents
{
    self.signs = @[@"!=", @"==", @"<=", @"<", @">", @">="];
    
    ZSCodeStatementIf *s = (ZSCodeStatementIf *)self.codeLine.statement;
    [self.exp1 setTitle: s.boolExp.exp1stringValue forState: UIControlStateNormal];
    [self.exp2 setTitle: s.boolExp.exp2stringValue forState: UIControlStateNormal];
    [self.sign setTitle: s.boolExp.sign            forState: UIControlStateNormal];
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.signs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    // Why is this not working ?
    // cell.textLabel.textColor = self.textLabel.textColor;
    
    cell.textLabel.textColor = [UIColor colorWithRed: 1
                                               green: 0.4
                                                blue: 0
                                               alpha: 1];
    cell.textLabel.font =  [UIFont fontWithName:@"Chalkboard SE" size:20];
    cell.textLabel.text = self.signs[indexPath.row];
    return cell;
}


- (IBAction)exp1Tapped:(id)sender
{
    ZSCodeEditorPopoverExpressionOptionsDataSource *s = [[ZSCodeEditorPopoverExpressionOptionsDataSource alloc]initWithAvailableVarNames:self.codeLine.statement.availableVarNames
                                                         StatementType:ZSCodeStatementTypeIf];
    ZSCodeEditorPopoverTableViewController *c
    = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain
                                                        dataSource:s];
    c.didSelectRowBlock = ^(NSInteger row)
    {
        // If new value
        if (row == 0)
        {
            ((ZSCodeStatementIf *)self.codeLine.statement).boolExp.exp1 = @"...";
        }
        // existing variable
        else
        {
            NSString *varName = self.codeLine.statement.availableVarNames[row - 1];
            ((ZSCodeStatementIf *)self.codeLine.statement).boolExp.exp1 = @{ @"get": varName };
        }
        [self.popover dismissPopoverAnimated:YES];
        [self updateCellContents];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}
- (IBAction)signTapped:(id)sender
{
    ZSCodeEditorPopoverTableViewController *c = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain dataSource:self];
    
    c.didSelectRowBlock = ^(NSInteger row)
    {
        ((ZSCodeStatementIf *)self.codeLine.statement).boolExp.sign = self.signs[row];
        [self updateCellContents];
        [self.popover dismissPopoverAnimated:YES];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}
- (IBAction)exp2Tapped:(id)sender
{
    ZSCodeEditorPopoverExpressionOptionsDataSource *s = [[ZSCodeEditorPopoverExpressionOptionsDataSource alloc]initWithAvailableVarNames:self.codeLine.statement.availableVarNames
                                                         StatementType:ZSCodeStatementTypeIf];
    ZSCodeEditorPopoverTableViewController *c
    = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain
                                                        dataSource:s];
    c.didSelectRowBlock = ^(NSInteger row)
    {
        // If new value
        if (row == 0)
        {
            ((ZSCodeStatementIf *)self.codeLine.statement).boolExp.exp2 = @"...";
        }
        // existing variable
        else
        {
            NSString *varName = self.codeLine.statement.availableVarNames[row - 1];
            ((ZSCodeStatementIf *)self.codeLine.statement).boolExp.exp2 = @{ @"get": varName };
        }
        [self.popover dismissPopoverAnimated:YES];
        [self updateCellContents];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}


@end
