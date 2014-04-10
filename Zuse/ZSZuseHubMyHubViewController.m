//
//  ZSZuseHubMyHubViewController.m
//  Zuse
//
//  Displays projects that are on the user's device so they can share them and also a
//  list of projects the user has already shared to ZuseHub.
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubMyHubViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMCenterTableViewCell.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMNavigationController.h"
#import "ZSZuseHubSideMenuViewController.h"
#import "ZSZuseHubShareViewController.h"
#import "ZSProjectPersistence.h"
#import "ZSProject.h"
#import "ZSZuseHubMySharedProjectDetailViewController.h"
#import "ZSProjectCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZSZuseHubMyHubViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *userProjects;
@property NSInteger currentPage;
@end

@implementation ZSZuseHubMyHubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userProjects = [[NSMutableArray alloc] init];
    self.currentPage = 1;
    
    self.navigationItem.title = @"ZuseHub";
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.view.tintColor = [UIColor zuseYellow];
    self.view.backgroundColor = [UIColor zuseBackgroundGrey];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    [self setupLeftMenuButton];
    
    UIColor *barColor = [UIColor
                          colorWithRed:247.0/255.0
                          green:249.0/255.0
                          blue:250.0/255.0
                          alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:barColor];
    
    if(self.contentType == ZSZuseHubMyHubTypeShareProject)
        self.title = @"Share Projects";
    else if(self.contentType == ZSZuseHubMyHubTypeViewMySharedProjects)
        self.title = @"My Shared Projects";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.contentType == ZSZuseHubMyHubTypeShareProject)
    {
        [self.userProjects addObjectsFromArray:[ZSProjectPersistence userProjects]];
        [self.collectionView reloadData];
    }
    else if(self.contentType == ZSZuseHubMyHubTypeViewMySharedProjects)
    {
        [self setupData];
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.userProjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZSProjectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    NSString *title;
    
    //display projects the user has on their device
    if(self.contentType == ZSZuseHubMyHubTypeShareProject)
    {
        ZSProject *project = self.userProjects[indexPath.row];
        title = project.title;
        if(project.screenshot)
            cell.screenshot = project.screenshot;
        else
            cell.screenshot = [UIImage imageNamed:@"blank_project.png"];
    }
    //display projects the user has already shared
    else if(self.contentType == ZSZuseHubMyHubTypeViewMySharedProjects)
    {
        NSDictionary *project = self.userProjects[indexPath.row];
        title = project[@"title"];
        [cell.screenshotView setImageWithURL:[NSURL URLWithString:project[@"screenshot_url"]] placeholderImage:[UIImage imageNamed:@"blank_project.png"]];
    }
    
    cell.projectTitle = title;
    
    [cell setNeedsLayout];
    
    return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //set up the left drawer animation
    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeParallax];
    
    NSInteger index = [self.collectionView.indexPathsForSelectedItems.firstObject row];
    
    //display the view to share the selected project.
    if(self.contentType == ZSZuseHubMyHubTypeShareProject)
    {
        ZSZuseHubShareViewController *controller = [[UIStoryboard storyboardWithName:@"Main"
                                                                              bundle:[NSBundle mainBundle]]
                                                    instantiateViewControllerWithIdentifier:@"ZuseHubShare"];
        controller.project = self.userProjects[index];
        [self presentViewController:controller animated:YES completion:^{}];
        controller.didFinish = ^(BOOL didShare){
            [self dismissViewControllerAnimated:YES completion:^{ }];
        };
        controller.didLogIn = ^(BOOL isLoggedIn){
            [self showLoginRegisterPage];
        };
    }
    //display the view that shows the detailed for the user's shared project
    else if(self.contentType == ZSZuseHubMyHubTypeViewMySharedProjects)
    {
        ZSZuseHubMySharedProjectDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main"
                                                                                              bundle:[NSBundle mainBundle]]
                                                                    instantiateViewControllerWithIdentifier:@"MySharedProjectDetail"];
        controller.project = self.userProjects[index];
        [self presentViewController:controller animated:YES completion:^{}];
        controller.didFinish = ^(){
            [self dismissViewControllerAnimated:YES completion:^{ }];
            [self setupData];
        };
    }
    else
        NSLog( @"TODO put different browse types");
    

}

/**
 * Set up the data source with the projects this user has shared
 */
- (void)setupData
{
    [self.jsonClientManager getUsersSharedProjects:self.currentPage itemsPerPage:10 completion:^(NSArray *projects, NSInteger statusCode)
    {
        if(projects)
        {
            self.userProjects = projects;
            [self.collectionView reloadData];
         }
         else{
             //TODO print msg for user
         }
    }];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

@end
