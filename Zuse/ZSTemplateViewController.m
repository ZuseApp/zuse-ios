//
//  ZSTemplateViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 1/13/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSTemplateViewController.h"
#import "ZSProject.h"
#import "ZSCanvasViewController.h"

@interface ZSTemplateViewController ()

@property (nonatomic, strong) NSString *bundleRoot;
@property (nonatomic, strong) NSMutableArray *filePaths;
@property (strong, nonatomic) IBOutlet UITableView *projectTableView;

@end

@implementation ZSTemplateViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // List template files in bundle.
        _bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:_bundleRoot error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
        _filePaths = [[dirContents filteredArrayUsingPredicate:fltr] mutableCopy];
        [self purgeTemplates];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)purgeTemplates {
    NSMutableArray *removeIndexes = [NSMutableArray array];
    for (NSInteger i = [_filePaths count] - 1; i >= 0; i--) {
        ZSProject *project = [ZSProject projectWithTemplate:_filePaths[i]];
        if (!project.version) {
            [removeIndexes addObject:@(i)];
        }
    }
    
    for (NSNumber *number in removeIndexes) {
        NSUInteger index = [number integerValue];
        [_filePaths removeObjectAtIndex:index];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_filePaths count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Open the project and get the title name.
    ZSProject *project = [ZSProject projectWithTemplate:_filePaths[indexPath.row]];
    if (project.title) {
        [cell.textLabel setText:project.title];
    }
    else {
        [cell.textLabel setText:@"No Title"];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"canvas"]) {
        ZSProject *project = [ZSProject projectWithTemplate:_filePaths[[_projectTableView indexPathForSelectedRow].row]];
        
        ZSCanvasViewController *controller = (ZSCanvasViewController *)segue.destinationViewController;
        controller.project = project;
        controller.didFinish = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
}

@end
