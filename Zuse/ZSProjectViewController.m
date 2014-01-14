//
//  ZSProjectViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 1/13/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSProjectViewController.h"
#import "ZSProject.h"
#import "ZSCanvasViewController.h"

@interface ZSProjectViewController ()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSMutableArray *filePaths;
@property (strong, nonatomic) IBOutlet UITableView *projectTableView;

@end

@implementation ZSProjectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // List user created files.
        [self loadDocuments];
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
    
    // Update table with most current information.
    [self loadDocuments];
    [self.tableView reloadData];
}

- (void)loadDocuments {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:_documentsDirectory error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
    _filePaths = [[dirContents filteredArrayUsingPredicate:fltr] mutableCopy];
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
    ZSProject *project = [ZSProject projectWithFile:_filePaths[indexPath.row]];
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
        ZSProject *project = [ZSProject projectWithFile:_filePaths[[_projectTableView indexPathForSelectedRow].row]];
        
        ZSCanvasViewController *controller = (ZSCanvasViewController *)segue.destinationViewController;
        controller.project = project;
        controller.didFinish = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Delete file from documents directory.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [_documentsDirectory stringByAppendingPathComponent:_filePaths[indexPath.row]];
    [fm removeItemAtPath:filePath error:nil];
    
    // Remove the file from the array.
    [_filePaths removeObjectAtIndex:indexPath.row];
    
    // Then perform the action on the tableView
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    
    // Finally, reload data in view
    [self.tableView reloadData];
}

@end