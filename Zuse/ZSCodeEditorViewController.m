#import "ZSCodeEditorViewController.h"
#import "ZSSetStatementEditorViewController.h"
#import "ZSIfStatementEditorViewController.h"
#import "ZSCallStatementEditorViewController.h"
#import "ZSCodeLine.h"
#import "ZSCodeObject.h"
#import "ZSCodeEditorTableViewCell.h"

@interface ZSCodeEditorViewController()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ZSCodeObject *object;
@property (strong, nonatomic) NSArray *codeLines;

@end


@implementation ZSCodeEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)processJSON:(NSDictionary *)json
{
    self.object = [ZSCodeObject codeObjectWithJSON:json];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // --- test
    
    NSLog(@"%@", self.object.JSONObject);
    
    // --- end test
    
    self.codeLines = self.object.codeLines; // get code lines
    return [self.codeLines count]; //return # of lines
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZSCodeLine *codeLine = self.codeLines[indexPath.row];
    ZSCodeEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:codeLine.type];
    cell.codeLine = codeLine;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30; // cell height
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
        ZSIfStatementEditorViewController *c = (ZSIfStatementEditorViewController *)segue.destinationViewController;
        //c.ifStatement = ((UITableViewCell *)sender).textLabel.text;
        NSLog(@"If Statement Editor.");
    }
    else if ([segue.identifier isEqualToString:@"call statement editor segue"])
    {
        NSLog(@"Call Statement Editor.");
        
        ZSCallStatementEditorViewController *c = (ZSCallStatementEditorViewController *)segue.destinationViewController;
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

@end
