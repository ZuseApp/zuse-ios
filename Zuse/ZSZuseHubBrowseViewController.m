//
//  ZSZuseHubBrowseViewController.m
//  Zuse
//
//  Allows the user to browse projects shared on ZuseHub even if not signed in.
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubBrowseViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMNavigationController.h"
#import "ZSZuseHubSideMenuViewController.h"
#import "ZSZuseHubBrowseProjectDetailViewController.h"
#import "ZSZuseHubShareViewController.h"
#import "ZSProjectCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <SVPullToRefresh/UIScrollView+SVInfiniteScrolling.h>

@interface ZSZuseHubBrowseViewController ()

@property (strong, nonatomic) NSArray *jsonProjectsFirst;
@property int currentPage;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) ZSZuseHubBrowseProjectDetailViewController *detailController;

@end

@implementation ZSZuseHubBrowseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentPage = 1;
    
    self.jsonProjectsFirst = @[];
    
    self.navigationItem.title = @"ZuseHub";
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.view.tintColor = [UIColor zuseYellow];
    self.view.backgroundColor = [UIColor zuseBackgroundGrey];
    
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
    
    if(self.contentType == ZSZuseHubBrowseTypeNewest)
        self.title = @"10 Newest Projects";
    else if(self.contentType == ZSZuseHubBrowseTypePopular)
        self.title = @"10 Most Popular Projects";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.jsonProjectsFirst = nil;
    //set up the data source
    if(self.contentType == ZSZuseHubBrowseTypeNewest)
    {
        [self.jsonClientManager getNewestProjects:1 itemsPerPage:10 completion:^(NSArray *projects) {
            if(projects)
            {
                self.jsonProjectsFirst = projects;
                [self.collectionView reloadData];
            }
            else
            {
                //TODO print something here for the user
            }
        }];

    }
    else if(self.contentType == ZSZuseHubBrowseTypePopular)
    {
        [self.jsonClientManager getPopularProjects:1 itemsPerPage:10 completion:^(NSArray *projects) {
            if(projects)
            {
                self.jsonProjectsFirst = projects;
                [self.collectionView reloadData];
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

#pragma mark - Table view data source

//TODO create sections to organize different browsing categories
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.jsonProjectsFirst.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZSProjectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    NSDictionary *project = self.jsonProjectsFirst[indexPath.row];
    
    cell.projectTitle = project[@"title"];
    UIImageView *temp = [[UIImageView alloc] init];
    [temp setImageWithURL:[NSURL URLWithString:project[@"screenshot_url"]] placeholderImage:[UIImage imageNamed:@"blank_project.png"]];
    cell.screenshot = temp.image;
    
    [cell setNeedsLayout];
    
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //set up the left drawer animation
    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeParallax];
    
    //display the details of the selected project.
    self.detailController = [[UIStoryboard storyboardWithName:@"Main"
                                                                          bundle:[NSBundle mainBundle]]
                                                instantiateViewControllerWithIdentifier:@"BrowseProjectDetail"];
    NSInteger index = [self.collectionView.indexPathsForSelectedItems.firstObject row];
    NSDictionary *project = self.jsonProjectsFirst[index];
    self.detailController.uuid = project[@"uuid"];
    [self presentViewController:self.detailController animated:YES completion:^{}];
    WeakSelf
    self.detailController.didDownloadProject = ^(ZSProject *project){
        weakSelf.didDownloadProject(project);
    };
    self.detailController.didFinish = ^(){
        [weakSelf.detailController dismissViewControllerAnimated:YES completion:^{ }];
    };
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

- (void)getNewestData:(int)page array:(NSArray *)array
{
    __block NSArray *tempArray = array;
    [self.jsonClientManager getNewestProjects:page itemsPerPage:10 completion:^(NSArray *projects) {
        if(projects)
        {
            tempArray = projects;
            [self.collectionView reloadData];
        }
        else
        {
            //TODO print something here for the user
        }
    }];
}

@end
