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

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
//    ZSCodeEditorOptionsViewController *
//    
//    controller.expressionTypes = ZSCodeEditorExpressionTypeAny |
//                                 ZSCodeEditorExpressionTypeBoolean
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"set statement editor segue"])
    {
        NSLog(@"Set Statement Editor.");
        ZSSetStatementEditorViewController *c = (ZSSetStatementEditorViewController *)segue.destinationViewController;
        c.codeLine = ((ZSCodeEditorTableViewCell *)sender).codeLine;
        
    }
    else if ([segue.identifier isEqualToString:@"if statement editor segue"])
    {
        //ZSIfStatementEditorViewController *c = (ZSIfStatementEditorViewController *)segue.destinationViewController;
        //c.ifStatement = ((UITableViewCell *)sender).textLabel.text;
        NSLog(@"If Statement Editor.");
    }
    else if ([segue.identifier isEqualToString:@"call statement editor segue"])
    {
        NSLog(@"Call Statement Editor.");
        
        //ZSCallStatementEditorViewController *c = (ZSCallStatementEditorViewController *)segue.destinationViewController;
        //c.codeLine = ((UITableViewCell *)sender).textLabel.text;
    }
    else if ([segue.identifier isEqualToString:@"on event statement editor segue"])
    {
        NSLog(@"On Event Statement Editor.");
    }
    else
    {
        NSLog(@"not implemented.");
    }
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
    self.codeLines = self.object.codeLines; // get code lines
    return [self.codeLines count]; //return # of lines
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get line of code
    ZSCodeLine *line = self.object.codeLines[indexPath.row];
    
    // get the cell
    ZSCodeEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:line.type];

    return cell;
}

#pragma mark - ZSCodeEditorViewController

- (void)processJSON:(NSDictionary *)json
{
    self.object = [ZSCodeObject codeObjectWithJSON:json];
}

@end
