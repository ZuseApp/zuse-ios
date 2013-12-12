#import "ZSCodeEditorPopoverExpressionOptionsDataSource.h"

@interface ZSCodeEditorPopoverExpressionOptionsDataSource()

@property (strong, nonatomic) NSMutableArray *availableVarNames;
@property (nonatomic) ZSCodeStatementType type;

@end

@implementation ZSCodeEditorPopoverExpressionOptionsDataSource

- (id) initWithAvailableVarNames:(NSArray *)n
                   StatementType:(ZSCodeStatementType) type
{
    if (self = [super init])
    {
        self.type = type;
        self.availableVarNames = [NSMutableArray arrayWithArray:n];
        [self.availableVarNames insertObject:@"Enter number..." atIndex:0];
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
    cell.textLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:20];
    
    
    switch (self.type)
    {
        case ZSCodeStatementTypeIf:
            cell.textLabel.textColor = [UIColor colorWithRed: 1
                                                       green: 0.4
                                                        blue: 0
                                                       alpha: 1];
            break;
        case ZSCodeStatementTypeSet:
            cell.textLabel.textColor = [UIColor colorWithRed: 0
                                                       green: 0.4
                                                        blue: 1
                                                       alpha: 1];
            break;
        default:
            break;
    }
    return cell;
}

@end
