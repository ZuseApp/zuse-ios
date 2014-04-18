#import "ZSTraitToggleViewController.h"
#import "ZSTraitEditorParametersViewController.h"
#import "ZS_CodeEditorViewController.h"
#import "ZSSpriteTraits.h"
#import <MTBlockAlertView/MTBlockAlertView.h>

@interface ZSTraitToggleViewController () <UITableViewDelegate, UITableViewDataSource>

// @property (strong, nonatomic) NSArray      *globalTraitNames;
@property (strong, nonatomic) NSMutableDictionary *allTraits;
@property (strong, nonatomic) NSArray *allTraitNames;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZSTraitToggleViewController

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
    
    if (self.enabledSpriteTraits[traitIdentifier]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:1.0
                                                           green:0
                                                            blue:0
                                                           alpha:0.3];
        
        if (((NSDictionary*)self.allTraits[traitIdentifier][@"parameters"]).count != 0) {
            UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
            optionsButton.frame = CGRectMake(254, 7, 56, 30);
            [optionsButton setTitle:@"Options" forState:UIControlStateNormal];
            [optionsButton addTarget:self action:@selector(options:) forControlEvents:UIControlEventTouchUpInside];
            optionsButton.tag = indexPath.row;
            [cell.contentView addSubview:optionsButton];
        }
        // [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)options:(id)sender {
    [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
    [self performSegueWithIdentifier:@"parameters" sender:sender];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *traitIdentifier = self.allTraitNames[indexPath.row];
    if (self.enabledSpriteTraits[traitIdentifier]) {
        [self.enabledSpriteTraits removeObjectForKey:traitIdentifier];
    } else {
        self.enabledSpriteTraits[traitIdentifier] = [@{
                                                       @"parameters": [self.allTraits[traitIdentifier][@"parameters"] mutableCopy]
                                                       } mutableCopy];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *traitIdentifier = self.allTraitNames[((UIButton*)sender).tag];
    
    // Merge any current trait parameters with the default, preferring the current
    NSMutableDictionary *defaultParams = [self.allTraits[traitIdentifier][@"parameters"] mutableCopy];
    [defaultParams addEntriesFromDictionary:self.enabledSpriteTraits[traitIdentifier][@"parameters"]];
    self.enabledSpriteTraits[traitIdentifier][@"parameters"] = defaultParams;
    
    if ([segue.identifier isEqualToString:@"parameters"]) {
        ZSTraitEditorParametersViewController *controller = (ZSTraitEditorParametersViewController *)segue.destinationViewController;
        controller.parameters = self.enabledSpriteTraits[traitIdentifier][@"parameters"];
    }
    else if ([segue.identifier isEqualToString:@"editor"]) {
        ZS_CodeEditorViewController *controller = (ZS_CodeEditorViewController*)segue.destinationViewController;
        
        NSMutableDictionary *spriteObject = [NSMutableDictionary dictionary];
        spriteObject[@"id"] = traitIdentifier;
        spriteObject[@"parameters"] = defaultParams;
        controller.codeItems = self.allTraits[traitIdentifier][@"code"];
        controller.initialProperties = [self.spriteProperties mutableCopy];
    }
}

@end
