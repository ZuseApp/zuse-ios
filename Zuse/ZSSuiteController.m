//
//  ZSSuiteController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/2/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSuiteController.h"

@implementation ZSSuiteController

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _suite.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSInteger row = indexPath.row;
    if (row < _suite.count) {
        NSString *command = _suite[row];
        if ([command isEqualToString:@"set"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"set"];
        } else if ([command isEqualToString:@"while"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"while"];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"add"];
    }
    return cell;
}

@end
