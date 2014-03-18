//
//  ZSZuseHubBrowseViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubBrowseViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMCenterTableViewCell.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMNavigationController.h"
#import "ZSZuseHubSideMenuViewController.h"
#import "ZSZuseHubBrowseProjectDetailViewController.h"
#import "ZSZuseHubShareViewController.h"

@interface ZSZuseHubBrowseViewController ()

@property (strong, nonatomic) NSArray *jsonProjects;

@end

@implementation ZSZuseHubBrowseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.jsonProjects = @[];
    
    self.navigationItem.title = @"ZuseHub";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    [self setupLeftMenuButton];
    
    UIColor * barColor = [UIColor
                              colorWithRed:247.0/255.0
                              green:249.0/255.0
                              blue:250.0/255.0
                              alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:barColor];
    
    
    UIView *backView = [[UIView alloc] init];
    [backView setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                 green:208.0/255.0
                                                  blue:208.0/255.0
                                                 alpha:1.0]];
    [self.tableView setBackgroundView:backView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.jsonProjects = nil;
    //set up the data source
    if(self.contentType == ZSZuseHubBrowseTypeNewest)
    {
        [self.jsonClientManager getNewestProjects:^(NSArray *projects) {
            if(projects)
            {
                self.jsonProjects = projects;
                [self.tableView reloadData];
            }
            else
            {
                //TODO print something here for the user
            }
        }];
    }
    else if(self.contentType == ZSZuseHubBrowseTypePopular)
    {
        [self.jsonClientManager getPopularProjects:^(NSArray *projects) {
            if(projects)
            {
                self.jsonProjects = projects;
                [self.tableView reloadData];
            }
            else{
                //TODO print something here for the user
            }
        }];
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)contentSizeDidChange:(NSString *)size{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

//TODO create sections to organize different browsing categories
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO make this get the size from the client data pulled from the server
    return self.jsonProjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    NSString *cellText;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MMCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    UIColor * selectedColor = [UIColor
                               colorWithRed:1.0/255.0
                               green:15.0/255.0
                               blue:25.0/255.0
                               alpha:1.0];
    
    //TODO set cellText to be what was grabbed from the client
    if(self.jsonProjects.count == 0)
    {
        cellText = @"No projects to display";
    }
    else
    {
        NSDictionary *project = self.jsonProjects[indexPath.row];
        cellText = project[@"title"];
    }

    //TODO grab info from json client for project titles
    [cell.textLabel setText:cellText];
    [cell.textLabel setTextColor:selectedColor];

    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.contentType == ZSZuseHubBrowseTypeNewest)
        return @"10 Newest Projects";
    else if(self.contentType == ZSZuseHubBrowseTypePopular)
        return @"10 Most Popular Projects";
    else
        return @"Select browse category";
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set up the left drawer animation
    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeParallax];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //display the details of the selected project.
    ZSZuseHubBrowseProjectDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main"
                                                                          bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"BrowseProjectDetail"];
    controller.project = self.jsonProjects[indexPath.row];
    [self presentViewController:controller animated:YES completion:^{}];
    controller.didFinish = ^(){

        [self dismissViewControllerAnimated:YES completion:^{ }];
        
    };
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

@end
