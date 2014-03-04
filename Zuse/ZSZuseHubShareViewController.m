//
//  ZSZuseHubShareViewController.m
//  Zuse
//
//  Created by Sarah Hong on 3/4/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubShareViewController.h"

@interface ZSZuseHubShareViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;

@end

@implementation ZSZuseHubShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                  green:208.0/255.0
                                                   blue:208.0/255.0
                                                  alpha:1.0]];
}
- (IBAction)cancelTapped:(id)sender {
    self.didFinish();
}
- (IBAction)shareTapped:(id)sender {
    if(self.titleTextField.text)
    {
        self.title = self.titleTextField.text;
    }
    if(self.descriptionTextField.text)
    {
        self.description = self.descriptionTextField.text;
    }
    self.didSelectShare();
}

@end
