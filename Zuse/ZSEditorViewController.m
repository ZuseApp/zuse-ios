//
//  ZSEditorViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/2/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSEditorViewController.h"
#import "ZSSuiteController.h"

@interface ZSEditorViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ZSSuiteController *rootSuiteController;
@end

@implementation ZSEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rootSuiteController = [[ZSSuiteController alloc] init];
    _rootSuiteController.suite = @[];
    _tableView.delegate   = _rootSuiteController;
    _tableView.dataSource = _rootSuiteController;
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
