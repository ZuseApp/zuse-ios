//
//  ZSSetStatementEditorViewController.h
//  Code Editor 2
//
//  Created by Vladimir on 10/21/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSSetStatementEditorViewController : UIViewController
@property (strong, nonatomic) NSString *setStatement;
@property (weak, nonatomic) IBOutlet UILabel *setLabel;
@end
