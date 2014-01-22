//
//  ZSTraitEditorViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSTraitEditorViewController.h"
#import "ZSTraitEditorParametersViewController.h"
#import "ZSSpriteTraits.h"

@interface ZSTraitEditorViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *globalTraits;
@property (strong, nonatomic) NSArray      *globalTraitNames;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ZSTraitEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _globalTraits     = [ZSSpriteTraits defaultTraits];
    _globalTraitNames = [_globalTraits allKeys];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _globalTraitNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *traitIdentifier = _globalTraitNames[indexPath.row];
    cell.textLabel.text = traitIdentifier;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    
    if (_traits[traitIdentifier]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:1.0
                                                           green:0
                                                            blue:0
                                                           alpha:0.3];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *traitIdentifier = _globalTraitNames[indexPath.row];
    if (_traits[traitIdentifier]) {
        [_traits removeObjectForKey:traitIdentifier];
    } else {
        _traits[traitIdentifier] = [@{
                @"parameters": [_globalTraits[traitIdentifier][@"parameters"] mutableCopy]
        } mutableCopy];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *traitIdentifier = _globalTraitNames[indexPath.row];
    ZSTraitEditorParametersViewController *controller = (ZSTraitEditorParametersViewController *)segue.destinationViewController;
    
    // Merge any current trait parameters with the default, preferring the current
    NSMutableDictionary *defaultParams = [_globalTraits[traitIdentifier][@"parameters"] mutableCopy];
    [defaultParams addEntriesFromDictionary:_traits[traitIdentifier][@"parameters"]];
    _traits[traitIdentifier][@"parameters"] = defaultParams;
    
    controller.parameters = _traits[traitIdentifier][@"parameters"];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"parameters" sender:self];
    
}

@end
