#import "ZSCodeEditorPopoverExpressionOptionsDataSource.h"

@implementation ZSCodeEditorPopoverExpressionOptionsDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];    
    cell.textLabel.text = [@(indexPath.row) stringValue];
    return cell;
}

@end
