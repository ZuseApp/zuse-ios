//
//  ZSTraitEditorViewController.m
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSTraitEditorViewController.h"
#import "ZSTraitEditorParametersViewController.h"
#import "ZS_CodeEditorViewController.h"
#import "ZSSpriteTraits.h"

NSString * const ZSTutorialBroadcastTraitToggled = @"ZSTutorialBroadcastTraitToggled";

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
        // cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        optionsButton.frame = CGRectMake(190, 7, 56, 30);
        [optionsButton setTitle:@"Options" forState:UIControlStateNormal];
        [optionsButton addTarget:self action:@selector(options:) forControlEvents:UIControlEventTouchUpInside];
        optionsButton.tag = indexPath.row;
        [cell.contentView addSubview:optionsButton];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    editButton.frame = CGRectMake(254, 7, 46, 30);
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    // editButton.tag = indexPath.row;
    [cell.contentView addSubview:editButton];
    
    return cell;
}

- (void)edit:(id)sender {
    [self performSegueWithIdentifier:@"editor" sender:self];
}

- (void)options:(id)sender {
    [self performSegueWithIdentifier:@"parameters" sender:self];
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
    
    // Merge any current trait parameters with the default, preferring the current
    NSMutableDictionary *defaultParams = [_globalTraits[traitIdentifier][@"parameters"] mutableCopy];
    [defaultParams addEntriesFromDictionary:_traits[traitIdentifier][@"parameters"]];
    _traits[traitIdentifier][@"parameters"] = defaultParams;
    
    if ([segue.identifier isEqualToString:@"parameters"]) {
        ZSTraitEditorParametersViewController *controller = (ZSTraitEditorParametersViewController *)segue.destinationViewController;
        controller.parameters = _traits[traitIdentifier][@"parameters"];
        [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastTraitToggled];
    }
    else {
        ZS_CodeEditorViewController *controller = (ZS_CodeEditorViewController*)segue.destinationViewController;
        NSMutableDictionary *spriteObject = [NSMutableDictionary dictionary];
        spriteObject[@"id"] = traitIdentifier;
        spriteObject[@"parameters"] = defaultParams;
        spriteObject[@"code"] = [_globalTraits[traitIdentifier][@"code"] mutableCopy];
        controller.json = spriteObject;
    }
}

- (void)createStageForName:(NSString *)name {
    CGRect rect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[ZSTutorial sharedTutorial] addActionWithText:@"Click here to toggle stuff."
                                          forEvent:ZSTutorialBroadcastTraitToggled
                                   allowedGestures:@[UITapGestureRecognizer.class]
                                      activeRegion:rect
                                             setup:nil
                                        completion:nil];
}

@end
