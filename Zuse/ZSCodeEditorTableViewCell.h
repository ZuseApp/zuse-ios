#import <UIKit/UIKit.h>
#import "ZSCodeLine.h"
#import "ZSCodeEditorViewController.h"
#import "ZSCodeEditorPopoverTableViewController.h"
#import <WYPopoverController/WYPopoverController.h>

@interface ZSCodeEditorTableViewCell : UITableViewCell <WYPopoverControllerDelegate>

@property (weak, nonatomic) ZSCodeLine *codeLine;
@property (weak, nonatomic) ZSCodeEditorViewController *viewController;
@property (strong, nonatomic) WYPopoverController *popover;

- (void)updateCellContents;
- (void)presentPopoverWithViewController:(UIViewController *)controller
                                  inView:(UIView *)view;

@end
