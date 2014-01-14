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
@property (nonatomic, strong) NSArray *filePaths;
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
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsDirectory = [paths objectAtIndex:0];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:_documentsDirectory error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.json'"];
         _filePaths = [dirContents filteredArrayUsingPredicate:fltr];
        
        NSLog(@"Project directory: %@", _documentsDirectory);
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

@end