//
//  ZSSettingsViewController.m
//  Zuse
//
//  Created by Michael Hogenson on 1/16/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSSettingsViewController.h"

@interface ZSSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *gridSizeLabel;
@property (weak, nonatomic) IBOutlet UISlider *gridSizeSlider;

@end

@implementation ZSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _gridSizeSlider.value = _grid.dimensions.width;
    [self updateLabel];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *) sender;
    
    float width = slider.value;
    float height = width * _grid.size.height / _grid.size.width;
    
    _grid.dimensions = CGSizeMake(width, height);
    [self updateLabel];
}

- (void)updateLabel {
    if (_grid.dimensions.width > 1 && _grid.dimensions.height > 1) {
        _gridSizeLabel.text = [NSString stringWithFormat:@"%f x %f", _grid.dimensions.width, _grid.dimensions.height];
    }
    else {
        _gridSizeLabel.text = @"Off";
    }
}

@end
