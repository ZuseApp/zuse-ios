//
//  ZSZuseHubShareViewController.m
//  Zuse
//
//  Shows a form where the user can fill out the project details to share a
//  project from their device.
//
//  Created by Sarah Hong on 3/4/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubShareViewController.h"

@interface ZSZuseHubShareViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorMsgLabel;

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
    self.titleTextLabel.text = self.project.title;
    self.descriptionTextField.layer.cornerRadius = 5.0f;
    self.descriptionTextField.clipsToBounds = YES;
    self.descriptionTextField.delegate = self;
    self.scrollView.bounds = self.view.bounds;
    self.view.backgroundColor = [UIColor zuseBackgroundGrey];
}

- (IBAction)outerViewTapped:(id)sender {
    [self.titleTextLabel resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
}
- (IBAction)cancelTapped:(id)sender {
    self.didFinish(NO);
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    self.scrollView.contentOffset = CGPointMake(0, textView.frame.origin.y);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length == 0)
    {
        textView.text = @"Enter description";
        textView.textColor = [UIColor blackColor];
    }
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (IBAction)shareTapped:(id)sender {
    self.errorMsgLabel.text = @"";
    if(self.titleTextLabel.text.length != 0 && self.descriptionTextField.text.length != 0 &&
       ![self.descriptionTextField.text isEqualToString:@"Enter description"])
    {
        //TODO have logic here to check if the project should use create or update endpoint
        [self.jsonClientManager createSharedProject:self.titleTextLabel.text description:self.descriptionTextField.text projectJson:self.project
         completion:^(NSArray *project, NSError *error, NSInteger statusCode)
        {
            //user not logged in
             if(statusCode == 401)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share Failed"
                                                                 message:@"You must sign in to share."
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 self.didLogIn(NO);
             }
             else
             {
                 if(error.localizedDescription.length == 0)
                 {
                     NSLog(@"share succeeded");
                     //TODO store the project JSON that came back
                     
                     
                 }
             }
         }];
        self.didFinish(YES);
    }
    else{
        self.errorMsgLabel.text = @"Fill in the description";
    }
}

@end
