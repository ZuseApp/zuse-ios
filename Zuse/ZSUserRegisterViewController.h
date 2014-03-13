//
//  ZSUserRegisterViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/11/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSUserRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (copy, nonatomic) void(^didFinish)();

@end
