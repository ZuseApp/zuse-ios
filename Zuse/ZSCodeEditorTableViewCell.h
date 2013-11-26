//
//  ZSCodeEditorTableViewCell.h
//  Zuse
//
//  Created by Vladimir on 11/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSCodeLine.h"

@interface ZSCodeEditorTableViewCell : UITableViewCell

@property (weak, nonatomic) ZSCodeLine *codeLine;

@end
