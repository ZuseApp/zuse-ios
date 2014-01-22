//
//  ZSTraitEditorParametersViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSTraitEditorParametersViewController.h"

@interface ZSTraitEditorParametersViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *parameterNames;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZSTraitEditorParametersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _parameterNames = [_parameters allKeys];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _parameterNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *parameterName = _parameterNames[indexPath.row];
    cell.textLabel.text = parameterName;
    
    if ([_parameters[parameterName] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *parameterName = _parameterNames[indexPath.row];
    
    // TODO: This should handle arbitrary literals eventually and have the same
    // interface as the properties editor.
    BOOL currentValue = [_parameters[parameterName] boolValue];
    _parameters[parameterName] = @((BOOL)(!currentValue));
    
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationNone];
    
}

@end
