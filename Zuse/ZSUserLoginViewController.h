//
//  ZSUserLoginViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/10/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSUserLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorMsgLabel;

@end
