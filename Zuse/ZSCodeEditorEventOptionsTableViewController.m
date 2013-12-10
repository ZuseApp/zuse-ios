//
//  ZSCodeEditorEventOptionsTableViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCodeEditorEventOptionsTableViewController.h"

@interface ZSCodeEditorEventOptionsTableViewController ()

@property (strong, nonatomic) NSArray *events;

@end

@implementation ZSCodeEditorEventOptionsTableViewController

- (void)viewDidLoad
{
//    [super viewDidLoad];
//    
//    [self.tableView registerClass:[UITableViewCell class]
//           forCellReuseIdentifier:@"Cell"];
//    
//    _events = @[ @"start", @"touch_began", @"touch_moved" ];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    cell.textLabel.text = _events[indexPath.row];
//    
//    return cell;
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    _didSelectEventBlock(_events[indexPath.row]);
}

@end
