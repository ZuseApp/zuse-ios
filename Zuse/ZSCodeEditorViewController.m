#import "ZSCodeEditorViewController.h"
#import "ZSSetStatementEditorViewController.h"
#import "ZSIfStatementEditorViewController.h"
#import "ZSCallStatementEditorViewController.h"
#import "ZSCodeLine.h"
#import "ZSCodeStatementObject.h"
#import "ZSCodeEditorTableViewCell.h"
#import "ZSCodeEditorTableViewCellSet.h"

@interface ZSCodeEditorViewController()

@property (strong, nonatomic) ZSCodeStatementObject *object;
@property (strong, nonatomic) NSArray *codeLines;

@end


@implementation ZSCodeEditorViewController


# pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

# pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // pass line of code to the cell
    ((ZSCodeEditorTableViewCell *)cell).codeLine = self.codeLines[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35; // cell height
}

#pragma mark - UITableViewDataSource delegated methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.codeLines = self.object.code.codeLines; // get code lines
    return [self.codeLines count]; //return # of lines
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get line of code
    ZSCodeLine *line = self.codeLines[indexPath.row];
    
    // get the cell
    ZSCodeEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[@(line.type) stringValue]];
    cell.viewController = self;
    
    return cell;
}

#pragma mark - ZSCodeEditorViewController

- (void)processJSON:(NSDictionary *)json
{
    self.object = [[ZSCodeStatementObject alloc] initWithJSON:json
                                         parentSuite:nil];
}

@end
