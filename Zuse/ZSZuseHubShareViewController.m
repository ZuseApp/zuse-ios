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

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *projectJson;
@property (strong, nonatomic) NSString *compiledCode;

@end

@implementation ZSZuseHubShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = @"ZuseHub";
    
    self.titleTextField.enabled = NO;
    self.titleTextField.text = self.project.title;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                  green:208.0/255.0
                                                   blue:208.0/255.0
                                                  alpha:1.0]];
}
- (IBAction)outerViewTapped:(id)sender {
    [self.titleTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
}
- (IBAction)cancelTapped:(id)sender {
    self.didFinish(NO);
}
- (IBAction)shareTapped:(id)sender {

    
    if(self.titleTextField.text.length != 0 && self.descriptionTextField.text.length != 0)
    {
    
    // JSON request
        [self.jsonClientManager createSharedProject:self.titleTextField.text description:self.descriptionTextField.text projectJson:self.project
         completion:^(NSError *error) {
             if(error.localizedDescription.length == 0)
                 NSLog(@"share succeeded");
         }];
     
        self.didFinish(YES);
    }
    
    
}

@end
