#import "ZSCodeEditorViewController.h"
#import "ZSSetStatementEditorViewController.h"
#import "ZSIfStatementEditorViewController.h"
#import "ZSCallStatementEditorViewController.h"
#import "ZSCodeLine.h"
#import "ZSCodeObject.h"


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
    // get line of code
    ZSCodeLine *line = self.codeLines[indexPath.row];
    
    // form text
    NSMutableString *text = [NSMutableString stringWithString:@""];
    for (NSInteger i = 0; i < line.indentation; i++)
    {
        [text appendString:@"       "];
    }
    [text appendString:line.text];
    
    // get cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:line.type];
    
    cell.textLabel.text = text;
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:14];
    
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
        c.setStatement = ((UITableViewCell *)sender).textLabel.text;
    }
    else if ([segue.identifier isEqualToString:@"if statement editor segue"])
    {
        ZSIfStatementEditorViewController *c = (ZSIfStatementEditorViewController *)segue.destinationViewController;
        c.ifStatement = ((UITableViewCell *)sender).textLabel.text;
        NSLog(@"If Statement Editor.");
    }
    else if ([segue.identifier isEqualToString:@"call statement editor segue"])
    {
        NSLog(@"Call Statement Editor.");
        
        ZSCallStatementEditorViewController *c = (ZSCallStatementEditorViewController *)segue.destinationViewController;
        c.codeLine = ((UITableViewCell *)sender).textLabel.text;
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
