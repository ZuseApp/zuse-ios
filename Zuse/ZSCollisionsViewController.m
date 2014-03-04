//
//  ZSCollisionsViewController.m
//  Zuse
//
//  Created by Parker Wightman on 2/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSProjectJSONKeys.h"
#import "ZSCollisionsViewController.h"

@interface ZSCollisionsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *collisionGroupNames;

@end

@implementation ZSCollisionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
    
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    
    _collisionGroupNames = _collisionGroups.allKeys;
    
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _collisionGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *groupName = _collisionGroupNames[indexPath.row];
    cell.textLabel.text = groupName;
    
    if ([_collisionGroups[_selectedGroup] indexOfObject:groupName] != NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (IBAction)doneButtonTapped:(id)sender {
    _didFinish();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tappedGroup = _collisionGroupNames[indexPath.row];
    
    /*
     * Toggle whether the _selectedGroup collides with the tappedGroup. Both collections
     * need to be updated to collide/not collide with each other, not just _selectedGroup
     */
    if ([_collisionGroups[_selectedGroup] indexOfObject:tappedGroup] == NSNotFound) {
        [_collisionGroups[_selectedGroup] addObject:tappedGroup];
        if ([_collisionGroups[tappedGroup] indexOfObject:_selectedGroup] == NSNotFound) {
            [_collisionGroups[tappedGroup] addObject:_selectedGroup];
        }
    } else {
        [_collisionGroups[_selectedGroup] removeObject:tappedGroup];
        if ([_collisionGroups[tappedGroup] indexOfObject:_selectedGroup] != NSNotFound) {
            [_collisionGroups[tappedGroup] removeObject:_selectedGroup];
        }
    }
    
    NSLog(@"%@", _collisionGroups);
    
    [_tableView reloadData];
}

@end
