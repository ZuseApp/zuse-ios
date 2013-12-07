#import "ZSVarNameOptionsTableViewController.h"

@interface ZSVarNameOptionsTableViewController ()

@end

@implementation ZSVarNameOptionsTableViewController

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
    return [self.varNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = self.varNames[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed: 0
                                               green: 0.4
                                                blue: 1
                                               alpha: 1];
    cell.textLabel.font =  [UIFont fontWithName:@"Chalkboard SE" size:20];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.didSelectValueBlock(self.varNames[indexPath.row]);
}

@end
