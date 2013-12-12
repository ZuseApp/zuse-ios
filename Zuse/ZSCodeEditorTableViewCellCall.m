#import "ZSCodeEditorTableViewCellCall.h"
#import "ZSCodeStatementCall.h"
@interface ZSCodeEditorTableViewCellCall()

@property (weak, nonatomic) IBOutlet UIButton *call;
@property (weak, nonatomic) IBOutlet UIButton *param1;
@property (weak, nonatomic) IBOutlet UIButton *param2;

@end

@implementation ZSCodeEditorTableViewCellCall

- (void)updateCellContents
{
    ZSCodeStatementCall *s = (ZSCodeStatementCall *)self.codeLine.statement;
    self.call.imageView.image = [UIImage imageNamed:@"move"];
    [self.param1 setTitle:[s.params[0] stringValue] forState:UIControlStateNormal];
    [self.param2 setTitle:[s.params[1] stringValue] forState:UIControlStateNormal];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = [@(indexPath.row) stringValue];
    cell.textLabel.textColor = [UIColor redColor];
    cell.textLabel.font =  [UIFont fontWithName:@"Chalkboard SE" size:20];
    return cell;
}

- (IBAction)param1Tapped:(id)sender
{
    ZSCodeEditorPopoverTableViewController *c = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain dataSource:self];
    
    c.didSelectRowBlock = ^(NSInteger i)
    {
        ZSCodeStatementCall *s = (ZSCodeStatementCall *)self.codeLine.statement;
        s.params[0] = @(i);
        [self.viewController.tableView reloadData];
        [self.popover dismissPopoverAnimated:YES];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}

- (IBAction)param2Tapped:(id)sender
{
    ZSCodeEditorPopoverTableViewController *c = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain dataSource:self];
    
    c.didSelectRowBlock = ^(NSInteger i)
    {
        ZSCodeStatementCall *s = (ZSCodeStatementCall *)self.codeLine.statement;
        s.params[1] = @(i);
        [self.viewController.tableView reloadData];
        [self.popover dismissPopoverAnimated:YES];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}

@end
