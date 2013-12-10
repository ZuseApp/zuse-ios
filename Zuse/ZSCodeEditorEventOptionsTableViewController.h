//
//  ZSCodeEditorEventOptionsTableViewController.h
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZSEventSelectionBlock)(NSString *value);

@interface ZSCodeEditorEventOptionsTableViewController : UITableViewController

@property (copy, nonatomic) ZSEventSelectionBlock didSelectEventBlock;

@end
