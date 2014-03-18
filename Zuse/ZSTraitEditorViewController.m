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
NSString * const ZSTutorialBroadcastBackPressedTraitEditor = @"ZSTutorialBroadcastBackPressed";
 
typedef NS_ENUM(NSInteger, ZSEditorTutorialStage) {
    ZSTraitEditorToggleTraitOne,
    ZSTraitEditorToggleTraitTwo
};

@interface ZSTraitEditorViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *globalTraits;
// @property (strong, nonatomic) NSArray      *globalTraitNames;
@property (strong, nonatomic) NSMutableDictionary *allTraits;
@property (strong, nonatomic) NSArray *allTraitNames;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ZSTutorial *tutorial;
@property (assign, nonatomic) ZSEditorTutorialStage tutorialStage;

@end

@implementation ZSTraitEditorViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tutorial = [ZSTutorial sharedTutorial];
        _tutorialStage = ZSTraitEditorToggleTraitOne;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _globalTraits     = [ZSSpriteTraits defaultTraits];
    // _globalTraitNames = [_globalTraits allKeys];
    
    self.allTraits = [_globalTraits deepMutableCopy];
    for (id key in self.traitImplementations) {
        [self.allTraits setObject:self.traitImplementations[key] forKey:key];
    }
    self.allTraitNames = [self.allTraits allKeys];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_tutorial.isActive) {
        [self createTutorialForStage:_tutorialStage];
        [_tutorial presentWithCompletion:^{
            _tutorialStage++;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allTraitNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *traitIdentifier = self.allTraitNames[indexPath.row];
    cell.textLabel.text = traitIdentifier;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    
    if (_traits[traitIdentifier]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:1.0
                                                           green:0
                                                            blue:0
                                                           alpha:0.3];
        
        if (((NSDictionary*)_allTraits[traitIdentifier][@"parameters"]).count != 0) {
            UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
            optionsButton.frame = CGRectMake(190, 7, 56, 30);
            [optionsButton setTitle:@"Options" forState:UIControlStateNormal];
            [optionsButton addTarget:self action:@selector(options:) forControlEvents:UIControlEventTouchUpInside];
            optionsButton.tag = indexPath.row;
            [cell.contentView addSubview:optionsButton];
        }
        [_tutorial broadcastEvent:ZSTutorialBroadcastTraitToggled];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *buttonTitle = indexPath.row < self.globalTraits.count ? @"View" : @"Edit";
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    editButton.frame = CGRectMake(254, 7, 46, 30);
    editButton.tag = indexPath.row;
    [editButton setTitle:buttonTitle forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];

    [cell.contentView addSubview:editButton];
    
    return cell;
}

- (void)edit:(id)sender {
    [self performSegueWithIdentifier:@"editor" sender:sender];
}

- (void)options:(id)sender {
    [self performSegueWithIdentifier:@"parameters" sender:sender];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *traitIdentifier = self.allTraitNames[indexPath.row];
    if (_traits[traitIdentifier]) {
        [_traits removeObjectForKey:traitIdentifier];
    } else {
        _traits[traitIdentifier] = [@{
                @"parameters": [_allTraits[traitIdentifier][@"parameters"] mutableCopy]
        } mutableCopy];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *traitIdentifier = self.allTraitNames[((UIButton*)sender).tag];
    
    // Merge any current trait parameters with the default, preferring the current
    NSMutableDictionary *defaultParams = [_allTraits[traitIdentifier][@"parameters"] mutableCopy];
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
        spriteObject[@"code"] = [_allTraits[traitIdentifier][@"code"] mutableCopy];
        controller.json = spriteObject;
    }
}

#pragma mark Tutorial

- (void)createTutorialForStage:(ZSEditorTutorialStage)stage {
    if (stage == ZSTraitEditorToggleTraitOne || stage == ZSTraitEditorToggleTraitTwo) {
        CGRect frame = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        frame.size.width = 254; // Remove edit button from touchable area.
        [[ZSTutorial sharedTutorial] addActionWithText:@"Click here to toggle trait."
                                              forEvent:ZSTutorialBroadcastTraitToggled
                                       allowedGestures:@[UITapGestureRecognizer.class]
                                          activeRegion:[_tableView convertRect:frame toView:self.view]
                                                 setup:nil
                                            completion:nil];
        frame = self.navigationController.navigationBar.frame;
        frame.size.width = 80;
        [[ZSTutorial sharedTutorial] addActionWithText:@"Press the back button to go back to the canvas."
                                              forEvent:ZSTutorialBroadcastBackPressedTraitEditor
                                       allowedGestures:@[UITapGestureRecognizer.class]
                                          activeRegion:frame
                                                 setup:nil
                                            completion:nil];
    }
}

@end
