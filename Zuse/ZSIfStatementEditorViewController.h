//
//  ZSIfStatementEditorViewController.h
//  Code Editor 2
//
//  Created by Vladimir on 10/21/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSIfStatementEditorViewController : UIViewController
@property (strong, nonatomic) NSString *ifStatement;
@property (weak, nonatomic) IBOutlet UILabel *ifLabel;

@end
