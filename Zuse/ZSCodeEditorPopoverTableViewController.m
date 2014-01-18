#import "ZSCodeEditorPopoverTableViewController.h"

@interface ZSCodeEditorPopoverTableViewController()

@property (strong, nonatomic) id<UITableViewDataSource> dataSource;

@end

@implementation ZSCodeEditorPopoverTableViewController

- (id)initWithStyle:(UITableViewStyle)style
         dataSource:(id<UITableViewDataSource>) dataSource
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.dataSource = dataSource;
        self.tableView.dataSource = dataSource;
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:@"Cell"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.didSelectRowBlock(indexPath.row);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
