#import "ZSCodeEditorStatementOptionsTableViewController.h"
#import "ZSCodeStatement.h"
#import "ZSCodeStatementIf.h"
#import "ZSCodeStatementSet.h"
#import "ZSCodeStatementOnEvent.h"
#import "ZSCodeSuite.h"
#import "ZSCodeLine.h"
@interface ZSCodeEditorStatementOptionsTableViewController ()

@end

@implementation ZSCodeEditorStatementOptionsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:@"Cell"];
    }
    return self;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.didSelectStatementBlock(indexPath.row);
}

@end
