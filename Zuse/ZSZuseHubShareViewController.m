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
#import "ZSProjectPersistence.h"

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

- (void)writeProject:(NSDictionary *)project
{
    NSString *JSONString = project[@"project_json"];
    NSError *error = nil;
    NSDictionary *projectJSONParsed = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options:0
                                                                        error:&error];
    
    assert(!error);
    
    ZSProject *zsProject = [ZSProject projectWithJSON:projectJSONParsed];
    [ZSProjectPersistence writeProject:zsProject];
}

- (IBAction)shareTapped:(id)sender {
    if(self.titleTextLabel.text.length != 0 && self.descriptionTextField.text.length != 0 &&
       ![self.descriptionTextField.text isEqualToString:@"Enter description"])
    {
        //TODO have logic here to check if the project should use create or update endpoint
        [self.jsonClientManager createSharedProject:self.titleTextLabel.text description:self.descriptionTextField.text projectJson:self.project
         completion:^(NSDictionary *project, NSError *error, NSInteger statusCode)
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
                 [self showLoginRegisterPage];
             }
            else if(statusCode == 409)
            {
                //try an update because this project could be on the server already
                [self.jsonClientManager updateSharedProject:self.titleTextLabel.text
                                                description:self.descriptionTextField.text projectJson:self.project
                                                 completion:^(NSDictionary *project, NSError *error, NSInteger statusCode) {
                    if(project)
                    {
                        //TODO create a project onto disk
//                        [self writeProject:project];
                        self.didFinish(YES);
                    }
                    else if (statusCode == 422)
                    {
                        //TODO display view to show that sharing failed
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share Failed"
                                                                        message:@"Your code has errors."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        self.didFinish(NO);
                    }
                }];
            }
            else if (statusCode == 422)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share Failed"
                                                                message:@"Your code has errors."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
             else if (statusCode == 201 || statusCode == 200)
             {
                 if(!error && project)
                 {
                     NSLog(@"share succeeded");
                     //TODO store the project JSON that came back
//                     [self writeProject:project];
                     
                     self.didFinish(YES);
                 }
                 //share failed
                 else{
                     self.didFinish(NO);
                 }
             }
            
         }];
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share Failed"
                                                        message:@"Make sure to enter a title and description."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
}

@end
