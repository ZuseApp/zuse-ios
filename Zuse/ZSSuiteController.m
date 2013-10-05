//
//  ZSSuiteController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/2/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSuiteController.h"

@interface ZSSuiteController ()

@property (strong, nonatomic) ZSSuiteController *test;

@end

@implementation ZSSuiteController

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _suite.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"command"];;
    
    CGFloat height = 170;
    CGFloat width = 320;
    
    NSInteger row = indexPath.row;
    if (row < _suite.count) {
        // Get rectangle of table view.
        
        NSString *command = _suite[row];
        if ([command isEqualToString:@"set"]) {
            cell.backgroundColor = [UIColor colorWithRed:1.0f green:0.94f blue:0.86f alpha:1.0f];
            UILabel *nestedLabel = [[UILabel alloc] init];
            nestedLabel.text = @"set";
            CGRect labelFrame = nestedLabel.frame;
            labelFrame.origin.x = 15;
            labelFrame.origin.y = 6;
            labelFrame.size.width = width - 15;
            labelFrame.size.height = 21;
            nestedLabel.frame = labelFrame;
            [cell.contentView addSubview:nestedLabel];
        } else if ([command isEqualToString:@"ask"]) {
            cell.backgroundColor = [UIColor colorWithRed:1.0f green:0.69f blue:0.96f alpha:1.0f];
            UILabel *nestedLabel = [[UILabel alloc] init];
            nestedLabel.text = @"ask";
            CGRect labelFrame = nestedLabel.frame;
            labelFrame.origin.x = 15;
            labelFrame.origin.y = 6;
            labelFrame.size.width = width - 15;
            labelFrame.size.height = 21;
            nestedLabel.frame = labelFrame;
            [cell.contentView addSubview:nestedLabel];
        } else if ([command isEqualToString:@"while"]) {
            cell.backgroundColor = [UIColor colorWithRed:1.0f green:0.65f blue:0.75f alpha:1.0f];
            
            UILabel *nestedLabel = [[UILabel alloc] init];
            nestedLabel.text = @"while";
            CGRect labelFrame = nestedLabel.frame;
            labelFrame.origin.x = 15;
            labelFrame.origin.y = 6;
            labelFrame.size.width = width - 15;
            labelFrame.size.height = 21;
            nestedLabel.frame = labelFrame;
            [cell.contentView addSubview:nestedLabel];
            
            UITableView *nestedTable = [[UITableView alloc] init];
            CGRect frame = nestedTable.frame;
            frame.origin.x = 3;
            frame.origin.y = 35;
            frame.size.width = width - 3;
            frame.size.height = height - 38;
            nestedTable.frame = frame;
            [nestedTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"command"];
            [cell.contentView addSubview:nestedTable];
            
            // Temp SuiteController
            _test = [[ZSSuiteController alloc] init];
            _test.suite = @[@"ask", @"set"];
            nestedTable.delegate = _test;
            nestedTable.dataSource = _test;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"command"];
        UILabel *nestedLabel = [[UILabel alloc] init];
        nestedLabel.text = @"+";
        CGRect labelFrame = nestedLabel.frame;
        labelFrame.origin.x = 15;
        labelFrame.origin.y = 6;
        labelFrame.size.width = width - 15;
        labelFrame.size.height = 21;
        nestedLabel.frame = labelFrame;
        [cell.contentView addSubview:nestedLabel];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 2) {
        return 170;
    }
    return 44;
    
}

@end
