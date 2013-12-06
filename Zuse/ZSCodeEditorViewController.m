#import "ZSCodeEditorViewController.h"
#import "ZSSetStatementEditorViewController.h"
#import "ZSIfStatementEditorViewController.h"
#import "ZSCallStatementEditorViewController.h"
#import "ZSCodeLine.h"
#import "ZSCodeObject.h"
#import "ZSCodeEditorTableViewCell.h"
#import "ZSCodeEditorSetStatementTableViewCell.h"

//typedef NS_ENUM(NSInteger, ZSCodeEditorExpressionType) {
//    ZSCodeEditorExpressionTypeNumeric = 1,
//    ZSCodeEditorExpressionTypeBoolean = 1 << 1,
//    ZSCodeEditorExpressionTypeString  = 1 << 2,
//    ZSCodeEditorExpressionTypeVariable = 1 << 3,
//    ZSCodeEditorExpressionTypeCreateVariable = 1 << 4,
//    ZSCodeEditorExpressionTypeAny     = 64
//};

@interface ZSCodeEditorViewController()

@property (strong, nonatomic) ZSCodeObject *object;
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
    // get line of code
    ZSCodeLine *line = self.codeLines[indexPath.row];

    ZSCodeEditorTableViewCell *c = (ZSCodeEditorTableViewCell *)cell;
    c.codeLine = line;
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
    ZSCodeEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:line.type];
    cell.controller = self;
    
    return cell;
}

#pragma mark - ZSCodeEditorViewController

- (void)processJSON:(NSDictionary *)json
{
    self.object = [[ZSCodeObject alloc] initWithJSON:json];
}

@end
