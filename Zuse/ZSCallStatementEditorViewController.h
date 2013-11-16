//
//  ZSCallStatementViewController.h
//  Code Editor 2
//
//  Created by Vladimir on 10/24/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSCallStatementEditorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *methodName;
@property (weak, nonatomic) IBOutlet UITextField *methodParams;
@property (strong, nonatomic) NSString *codeLine;

@end
