//
//  ZSMainMenuViewController.m
//  Zuse
//
//  Created by Parker Wightman on 2/27/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <MTBlockAlertView/MTBlockAlertView.h>

#import "ZSMainMenuViewController.h"
#import "ZSProjectCollectionViewCell.h"
#import "ZSProjectPersistence.h"
#import "ZSCanvasViewController.h"
#import "ZSTutorial.h"
#import "UIImageView+Zuse.h"
#import "ZSZuseHubViewController.h"

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
@property (strong, nonatomic) ZSZuseHubViewController *zuseHubController;

@end

@implementation ZSMainMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.zuseHubController = [[ZSZuseHubViewController alloc] init];
//    self.zuseHubController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    self.projectCollectionView.delegate = self;
    self.projectCollectionView.dataSource = self;
    self.view.tintColor = [UIColor zuseYellow];
    
    self.view.backgroundColor = [UIColor zuseBackgroundGrey];
    
    self.projectFilter = ZSMainMenuProjectFilterExamples;
    [self reloadDataSources];
}

- (void)viewWillAppear:(BOOL)animated {
//    [self reloadDataSources];
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

- (void)segueToProject:(ZSProject *)project {
    CGRect canvasFrames = [[UIScreen mainScreen] bounds];
    canvasFrames.size.height -= 44;
    
    NSArray *sizeArray = project.rawJSON[@"canvas_size"];
    CGFloat projectHeight = [sizeArray[1] floatValue];
    CGFloat scale = canvasFrames.size.height / projectHeight;
    
    if (scale == 1) {
        UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"CanvasNav"];
        navController.view.backgroundColor = [UIColor clearColor];
        navController.toolbar.translucent = NO;
        
        
        ZSCanvasViewController *controller = (ZSCanvasViewController *)navController.viewControllers.firstObject;
        //        ZSCanvasViewController *controller = (ZSCanvasViewController *)segue.destinationViewController;
        
        controller.project = self.selectedProject;
        
        NSIndexPath *indexPath = [self.projectCollectionView indexPathsForSelectedItems].firstObject;
        ZSProjectCollectionViewCell *cell = (ZSProjectCollectionViewCell *)[self.projectCollectionView cellForItemAtIndexPath:indexPath];
        
        CGRect rect = cell.screenshotView.imageFrame;
        
        rect = [cell.screenshotView convertRect:rect toView:self.view];
        
        controller.initialCanvasRect = rect;
        //    navController.modalPresentationStyle = UIModalPresentationNone;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        WeakSelf
        //    __weak typeof(navController) weakNavController = navController;
        //        __weak typeof(controller) weakNavController = controller;
        controller.didFinish = ^{
            [weakSelf dismissViewControllerAnimated:NO completion:^{ }];
            //            [weakNavController.view removeFromSuperview];
            //            [weakSelf.view.subviews.lastObject removeFromSuperview];
            [weakSelf reloadDataSources];
            [weakSelf scrollToBeginningWithCompletion:^(BOOL finished){ }];
        };
        
        [self presentViewController:navController
                           animated:NO
                         completion:^{}];
    }
    else {
        MTBlockAlertView *alertView = [[MTBlockAlertView alloc]
                                       initWithTitle:@"Unsupported Project"
                                       message:@"Zuse currently doesn't support loading projects that were created on different size phones."
                                       completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           
                                       }
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        alertView.alertViewStyle = UIAlertViewStyleDefault;
        [alertView show];
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
    
    ZSProject *project = self.selectedProjects[indexPath.row];
    
    cell.projectTitle = project.title;
    cell.screenshot = project.screenshot ?: [UIImage imageNamed:@"blank_project.png"];
    
    [cell setNeedsLayout];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self.projectCollectionView.indexPathsForSelectedItems.firstObject row];
    self.selectedProject = _selectedProjects[index];
    [self segueToProject:self.selectedProject];
}

- (IBAction)zuseHubTapped:(id)sender {    
    self.zuseHubController = [[ZSZuseHubViewController alloc] init];
    WeakSelf
    self.zuseHubController.didFinish = ^{
        [weakSelf.zuseHubController dismissViewControllerAnimated:YES completion:^{}];
    };
    self.zuseHubController.didDownloadProject = ^(ZSProject *project) {
        weakSelf.projectFilter = ZSMainMenuProjectFilterMyProjects;
        [weakSelf reloadDataSources];
        BOOL wasPersisted = [ZSProjectPersistence isProjectPersisted:project];
        [ZSProjectPersistence writeProject:project];
        weakSelf.selectedProject = project;
        [weakSelf.zuseHubController dismissViewControllerAnimated:YES
                                 completion:^{
//
                                     if (wasPersisted) {
                                         [weakSelf segueToProject:project];
                                     } else {
                                         [weakSelf insertAndSegueToNewProject:project];
                                     }
                                 }];
    };
    self.zuseHubController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:self.zuseHubController animated:YES completion:^{}];
}

- (IBAction)newProjectTapped:(id)sender {
    self.projectFilter = ZSMainMenuProjectFilterMyProjects;
    [self reloadDataSources];
    
    MTBlockAlertView *alertView = [[MTBlockAlertView alloc]
                                   initWithTitle:@"New Project"
                                         message:@"Enter a title for your new project"
                               completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   if (buttonIndex == 0) {
                                       NSString *title = [alertView textFieldAtIndex:0].text;
                                       self.selectedProject = [[ZSProject alloc] init];
                                       self.selectedProject.title = title;
                                       self.selectedProject.screenshot = [UIImage imageNamed:@"blank_project.png"];
                                       
                                       [ZSProjectPersistence writeProject:self.selectedProject];
                                       
                                       [self insertAndSegueToNewProject:self.selectedProject];
                                   }
                               }
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:@"Cancel", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)insertAndSegueToNewProject:(ZSProject *)project {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self scrollToBeginningWithCompletion:^(BOOL finished){
        [self.projectCollectionView performBatchUpdates:^{
            [self reloadDataSources];
            [self.projectCollectionView insertItemsAtIndexPaths:@[ indexPath ]];
        } completion:^(BOOL finished) {
            [self.projectCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            [self segueToProject:self.selectedProject];
        }];
    }];
}

- (void)scrollToBeginningWithCompletion:(void(^)(BOOL))completion {
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect bounds = self.projectCollectionView.bounds;
                         bounds.origin.x = 0;
                         self.projectCollectionView.bounds = bounds;
                     } completion:completion];
}

- (IBAction)tutorialTapped:(id)sender {
    self.projectFilter = ZSMainMenuProjectFilterMyProjects;
    [self reloadDataSources];
    
    [ZSTutorial sharedTutorial].active = YES;
    self.selectedProject = [[ZSProject alloc] init];
    self.selectedProject.title = @"Tutorial";
    self.selectedProject.screenshot = [UIImage imageNamed:@"blank_project.png"];
    [ZSProjectPersistence writeProject:self.selectedProject];
    [self insertAndSegueToNewProject:self.selectedProject];
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
