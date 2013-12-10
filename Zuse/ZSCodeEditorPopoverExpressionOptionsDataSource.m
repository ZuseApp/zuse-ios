#import "ZSCodeEditorPopoverExpressionOptionsDataSource.h"

@implementation ZSCodeEditorPopoverExpressionOptionsDataSource

- (id) initWithAvailableVarNames:(NSArray *)n
{
    if (self = [super init])
    {
        self.availableVarNames = [NSMutableArray arrayWithArray:n];
        [self.availableVarNames insertObject:@"CREATE VALUE" atIndex:0];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.availableVarNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.availableVarNames[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed: 0
                                               green: 0.4
                                                blue: 1
                                               alpha: 1];
    cell.textLabel.font =  [UIFont fontWithName:@"Chalkboard SE" size:20];
    return cell;
}

@end
