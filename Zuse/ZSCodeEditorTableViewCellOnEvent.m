#import "ZSCodeEditorTableViewCellOnEvent.h"
#import "ZSCodeEditorEventOptionsTableViewController.h"
#import "ZSCodeStatementOnEvent.h"

@interface ZSCodeEditorTableViewCellOnEvent()

@property (weak, nonatomic) IBOutlet UIButton *eventButton;
@property (strong, nonatomic) NSArray *events;
@end

@implementation ZSCodeEditorTableViewCellOnEvent

- (void)updateCellContents
{
    self.events = @[ @"start", @"touch_began", @"touch_moved" ];
    ZSCodeStatementOnEvent *s = (ZSCodeStatementOnEvent *)self.codeLine.statement;
    [self.eventButton setTitle:s.eventName forState:UIControlStateNormal];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.events[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed: 0
                                               green: 1
                                                blue: 0.4
                                               alpha: 1];
    cell.textLabel.font =  [UIFont fontWithName:@"Chalkboard SE" size:20];

    return cell;
}

- (IBAction)eventButtonTapped:(id)sender
{
    ZSCodeEditorPopoverTableViewController *c = [[ZSCodeEditorPopoverTableViewController alloc]initWithStyle:UITableViewStylePlain dataSource:self];
    
    c.didSelectRowBlock = ^(NSInteger i)
    {
        ZSCodeStatementOnEvent *s = (ZSCodeStatementOnEvent *)self.codeLine.statement;
        s.eventName = self.events[i];
        s.parameters = [[NSMutableArray alloc]initWithArray:(i ? @[@"touch_x", @"touch_y"] : @[])];
        [self updateCellContents];
        [self.popover dismissPopoverAnimated:YES];
    };
    [self presentPopoverWithViewController:c
                                    inView:sender];
}

@end
