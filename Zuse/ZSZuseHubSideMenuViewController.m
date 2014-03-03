//
//  ZSZuseHubSideMenuViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubSideMenuViewController.h"

@interface ZSZuseHubSideMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableViewCell *newestProjectsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *shareProjectCell;
@property (strong, nonatomic) NSArray *browseMenuStrings;

@end

@implementation ZSZuseHubSideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    _browseMenuStrings = @[@"Share my projects", @"Browse projects", @"View my shared projects"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.browseMenuStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Check if a reusable cell object was dequeued
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Populate the cell with the appropriate name based on the indexPath
    cell.textLabel.text = [_browseMenuStrings objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.newestProjectsCell) {
        self.didSelectNewestProjects();
    } else if (selectedCell == self.shareProjectCell) {
        self.didSelectShareProject();
    }
}

@end
