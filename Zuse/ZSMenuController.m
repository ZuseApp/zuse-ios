//
//  ZSMenuController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSMenuController.h"

@implementation ZSMenuController
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"play"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"play.png"];
    }
    else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"pause.png"];
    }
    else if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"stop.png"];
    }
    else if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"settings.png"];
    }
    else if (indexPath.row == 4) {
        cell.imageView.image = [UIImage imageNamed:@"back_arrow.png"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && _playSelected) {
        _playSelected();
    }
    else if (indexPath.row == 1 && _pauseSelected) {
        _pauseSelected();
    }
    else if (indexPath.row == 2 && _stopSelected) {
        _stopSelected();
    }
    else if (indexPath.row == 3 && _settingsSelected) {
        _settingsSelected();
    }
    else if (indexPath.row == 4 && _backSelected) {
        _backSelected();
    }
}


@end
