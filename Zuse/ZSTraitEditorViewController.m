#import "ZSTraitEditorViewController.h"
#import "ZSTraitEditorParametersViewController.h"
#import "ZS_CodeEditorViewController.h"
#import "ZSSpriteTraits.h"
#import <MTBlockAlertView/MTBlockAlertView.h>
#import "ZSZuseDSL.h"

NSString * const ZSTutorialBroadcastTraitToggled = @"ZSTutorialBroadcastTraitToggled";
NSString * const ZSTutorialBroadcastBackPressedTraitEditor = @"ZSTutorialBroadcastBackPressed";

@interface ZSTraitEditorViewController () <UITableViewDelegate, UITableViewDataSource>

// @property (strong, nonatomic) NSArray      *globalTraitNames;
@property (strong, nonatomic) NSMutableDictionary *allTraits;
@property (strong, nonatomic) NSArray *allTraitNames;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZSTraitEditorViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self
                                                                                               action:@selector(addTapped:)];
    [self reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)addTapped:(id)sender {
    NSLog(@"Working");
    
    MTBlockAlertView *alertView = [[MTBlockAlertView alloc] initWithTitle:@"New Trait"
                                                                  message:@"Enter the name of your new trait"
                                                          completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                              NSString *text = [alertView textFieldAtIndex:0].text;
                                                              NSMutableDictionary *emptyTrait = [@{
                                                                                                   @"code": @[],
                                                                                                   @"parameters": @{}
                                                                                                   } deepMutableCopy];
                                                              // TODO: Do a more thorough check to make sure it doesn't conflict
                                                              // with existing trait names, etc.
                                                              if (text && text.length > 0) {
                                                                  self.projectTraits[text] = emptyTrait;
                                                                  [self reloadData];
                                                              }
                                                              
                                                              
                                                          } cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)reloadData {
    self.allTraits = [self.globalTraits deepMutableCopy];
    for (id key in self.projectTraits) {
        [self.allTraits setObject:self.projectTraits[key] forKey:key];
    }
    self.allTraitNames = [self.allTraits allKeys];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allTraitNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSString *traitIdentifier = self.allTraitNames[indexPath.row];
    cell.textLabel.text = traitIdentifier;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    
    // Code kept from the case where the cell wasn't selected.  Can it be removed?
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *buttonTitle = self.globalTraits[traitIdentifier] ? @"View" : @"Edit";
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    editButton.frame = CGRectMake(254, 7, 46, 30);
    editButton.tag = indexPath.row;
    [editButton setTitle:buttonTitle forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];

    [cell.contentView addSubview:editButton];
    
    return cell;
}

- (void)edit:(id)sender {
    [self performSegueWithIdentifier:@"editor" sender:sender];
}

- (void)options:(id)sender {
    [self performSegueWithIdentifier:@"parameters" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *traitIdentifier = self.allTraitNames[((UIButton*)sender).tag];
    
    NSMutableDictionary *defaultParams = [self.allTraits[traitIdentifier][@"parameters"] mutableCopy];
    if ([segue.identifier isEqualToString:@"editor"]) {
        ZS_CodeEditorViewController *controller = (ZS_CodeEditorViewController*)segue.destinationViewController;
        
        NSMutableDictionary *spriteObject = [NSMutableDictionary dictionary];
        spriteObject[@"id"] = traitIdentifier;
        spriteObject[@"parameters"] = defaultParams;
        controller.codeItems = self.allTraits[traitIdentifier][@"code"];
        controller.initialProperties = [ZSZuseDSL propertiesJSON];
    }
}

@end
