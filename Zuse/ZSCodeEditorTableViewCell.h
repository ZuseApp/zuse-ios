#import <UIKit/UIKit.h>
#import "ZSCodeLine.h"
#import "ZSCodeEditorViewController.h"
#import "ZSPopoverController.h"

@interface ZSCodeEditorTableViewCell : UITableViewCell <WYPopoverControllerDelegate>

@property (weak, nonatomic) ZSCodeLine *codeLine;
@property (weak, nonatomic) ZSCodeEditorViewController *controller;
@property (strong, nonatomic) ZSPopoverController *popover;

- (void)updateCellContents;
- (void)presentPopoverWithViewController:(UIViewController *)controller
                                  inView:(UIView *)view;

@end
