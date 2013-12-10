#import "ZSCodeEditorTableViewCellNew.h"
#import "ZSCodeStatementNew.h"
#import "ZSCodeEditorPopoverTableViewController.h"

@interface ZSCodeEditorTableViewCellNew()

@property (weak, nonatomic) IBOutlet UIButton *button;

- (IBAction)buttonTapped:(id)sender;

@end

@implementation ZSCodeEditorTableViewCellNew

- (void) updateCellContents
{
    ZSCodeStatementType type = ((ZSCodeStatementNew *)self.codeLine.statement).parentCodeStatementType;
    
    // Change the image of the button
    switch (type)
    {
        case ZSCodeStatementTypeOnEvent:
            self.button.imageView.image = [UIImage imageNamed:@"plus event"];
            break;
        case ZSCodeStatementTypeIf:
            self.button.imageView.image = [UIImage imageNamed:@"plus if"];
            break;
        default:
            self.button.imageView.image = [UIImage imageNamed:@"plus"];
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ZSCodeStatementTypeNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    switch (indexPath.row)
    {
        case ZSCodeStatementTypeSet:
            cell.textLabel.text = @"SET";
            break;
        case ZSCodeStatementTypeIf:
            cell.textLabel.text = @"IF";
            break;
        case ZSCodeStatementTypeOnEvent:
            cell.textLabel.text = @"ON EVENT";
            break;
        case ZSCodeStatementTypeCall:
            cell.textLabel.text = @"CALL";
            break;
        default:
            @throw @"ZSCodeStatementOptionsTableViewController: unknown statement type";
            break;
    }
    return cell;
}

- (IBAction)buttonTapped:(id)sender
{
    ZSCodeEditorPopoverTableViewController *c = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain dataSource:self];
    
    c.didSelectRowBlock = ^(ZSCodeStatementType s)
    {
        [self.codeLine.statement.parentSuite addEmptyStatementWithType:s];
        [self.popover dismissPopoverAnimated:YES];
        [self.viewController.tableView reloadData];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}


@end
