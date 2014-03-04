//
//  ZSMainMenuViewController.m
//  Zuse
//
//  Created by Parker Wightman on 2/27/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSMainMenuViewController.h"
#import "ZSProjectCollectionViewCell.h"
#import "ZSProjectPersistence.h"
#import "ZSZuseHubViewController.h"
#import "ZSCanvasViewController.h"
#import <MTBlockAlertView/MTBlockAlertView.h>
#import "ZSTutorial.h"

typedef NS_ENUM(NSInteger, ZSMainMenuProjectFilter) {
    ZSMainMenuProjectFilterMyProjects,
    ZSMainMenuProjectFilterExamples
};

@interface ZSMainMenuViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *projectCollectionView;
@property (strong, nonatomic) NSArray *exampleProjects;
@property (strong, nonatomic) NSArray *userProjects;
@property (weak, nonatomic) NSArray *selectedProjects;
@property (strong, nonatomic) ZSProject *selectedProject;
@property (assign, nonatomic) ZSMainMenuProjectFilter projectFilter;

@end

@implementation ZSMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.projectCollectionView.delegate = self;
    self.projectCollectionView.dataSource = self;
    
    self.view.backgroundColor = [UIColor zuseBackgroundGrey];
    
    self.projectFilter = ZSMainMenuProjectFilterExamples;
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadDataSources];
}

- (void)reloadDataSources {
    self.exampleProjects = [ZSProjectPersistence exampleProjects];
    self.userProjects = [ZSProjectPersistence userProjects];
    if (self.projectFilter == ZSMainMenuProjectFilterExamples) {
        self.selectedProjects = self.exampleProjects;
    } else {
        self.selectedProjects = self.userProjects;
    }
    [self.projectCollectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"project"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        
        ZSCanvasViewController *controller = (ZSCanvasViewController *)navController.viewControllers.firstObject;
        controller.project = self.selectedProject;
        controller.didFinish = ^{
            [self dismissViewControllerAnimated:YES
                                     completion:^{ }];
        };
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedProjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZSProjectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectCell" forIndexPath:indexPath];
    
    cell.projectTitle = [self.selectedProjects[indexPath.row] title];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [[[self.projectCollectionView indexPathsForSelectedItems] firstObject] row];
    self.selectedProject = _selectedProjects[index];
    [self performSegueWithIdentifier:@"project" sender:self];
}

- (IBAction)zuseHubTapped:(id)sender {
    ZSZuseHubViewController *controller = [[ZSZuseHubViewController alloc] init];
    [self presentViewController:controller animated:YES completion:^{}];
}

- (IBAction)newProjectTapped:(id)sender {
    
    MTBlockAlertView *alertView = [[MTBlockAlertView alloc]
                                   initWithTitle:@"New Project"
                                         message:@"Enter a title for your new project"
                               completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == 0) {
                                       NSString *title = [alertView textFieldAtIndex:0].text;
                                       self.selectedProject = [[ZSProject alloc] init];
                                       self.selectedProject.title = title;
                                       [self performSegueWithIdentifier:@"project" sender:self];
                                   }
                               }
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:@"Cancel", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (IBAction)tutorialTapped:(id)sender {
    [ZSTutorial sharedTutorial].active = YES;
    self.selectedProject = [[ZSProject alloc] init];
    self.selectedProject.title = @"Tutorial";
    [self performSegueWithIdentifier:@"project" sender:self];
}

- (IBAction)myProjectsTapped:(id)sender {
    self.projectFilter = ZSMainMenuProjectFilterMyProjects;
    [self reloadDataSources];
}

- (IBAction)examplesTapped:(id)sender {
    self.projectFilter = ZSMainMenuProjectFilterExamples;
    [self reloadDataSources];
}

@end
