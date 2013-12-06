#import <UIKit/UIKit.h>
#import "ZSCodeLine.h"
#import "ZSCodeEditorViewController.h"

@interface ZSCodeEditorTableViewCell : UITableViewCell

@property (weak, nonatomic) ZSCodeLine *codeLine;
@property (weak, nonatomic) ZSCodeEditorViewController *controller;

- (void)updateCellContents;

@end
