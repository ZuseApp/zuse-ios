//
//  ZSZuseHubSideMenuViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubSideMenuViewController.h"
#import "MMSideDrawerTableViewCell.h"

@interface ZSZuseHubSideMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *newestProjectsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *shareProjectCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *viewMySharedProjectsCell;
@property (strong, nonatomic) NSArray *browseMenuStrings;
@property (strong, nonatomic) NSArray *myZuseHubMenuStrings;

@end

@implementation ZSZuseHubSideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    //TODO put the other browse filter strings here
    _browseMenuStrings = @[@"Browse newest projects"];
    _myZuseHubMenuStrings = @[@"Share my projects", @"View my shared projects"];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    UIColor * tableViewBackgroundColor = [UIColor colorWithRed:110.0/255.0
                                               green:113.0/255.0
                                                blue:115.0/255.0
                                               alpha:1.0];
    
    [self.tableView setBackgroundColor:tableViewBackgroundColor];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:66.0/255.0
                                                  green:69.0/255.0
                                                   blue:71.0/255.0
                                                  alpha:1.0]];
    
    UIColor * barColor = [UIColor colorWithRed:161.0/255.0
                                         green:164.0/255.0
                                          blue:166.0/255.0
                                         alpha:1.0];
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]){
        [self.navigationController.navigationBar setBarTintColor:barColor];
    }
    else {
        [self.navigationController.navigationBar setTintColor:barColor];
    }
    
    
    NSDictionary *navBarTitleDict;
    UIColor * titleColor = [UIColor colorWithRed:55.0/255.0
                                           green:70.0/255.0
                                            blue:77.0/255.0
                                           alpha:1.0];
    navBarTitleDict = @{NSForegroundColorAttributeName:titleColor};
    [self.navigationController.navigationBar setTitleTextAttributes:navBarTitleDict];
    
    self.drawerWidth = 160;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections-1)] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)contentSizeDidChange:(NSString *)size{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ZSZuseHubDrawerSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case ZSZuseHubDrawerMyZuseHub:
            return _myZuseHubMenuStrings.count;
        case ZSZuseHubDrawerBrowseProjects:
            return _browseMenuStrings.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[MMSideDrawerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    switch (indexPath.section) {
        case ZSZuseHubDrawerMyZuseHub:
            [cell.textLabel setText:_myZuseHubMenuStrings[indexPath.row]];
            break;
        case ZSZuseHubDrawerBrowseProjects:
            [cell.textLabel setText:_browseMenuStrings[indexPath.row]];
            break;
        default:
            break;
    }
    //place an arrow to show it can be selected
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case ZSZuseHubDrawerMyZuseHub:
            return @"My ZuseHub";
        case ZSZuseHubDrawerBrowseProjects:
            return @"Browse Projects";
        default:
            return nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.newestProjectsCell) {
        self.didSelectNewestProjects();
    } else if (selectedCell == self.shareProjectCell) {
        self.didSelectShareProject();
    }
    else if(selectedCell == self.viewMySharedProjectsCell)
    {
        self.didSelectViewMySharedProjects();
    }
}

@end
