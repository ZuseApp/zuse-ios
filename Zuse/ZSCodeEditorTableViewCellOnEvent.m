#import "ZSCodeEditorTableViewCellOnEvent.h"
#import "ZSCodeEditorEventOptionsTableViewController.h"
#import "ZSCodeStatementOnEvent.h"

@interface ZSCodeEditorTableViewCellOnEvent()

@property (weak, nonatomic) IBOutlet UIButton *eventButton;

@end

@implementation ZSCodeEditorTableViewCellOnEvent

- (void)updateCellContents
{
    ZSCodeStatementOnEvent *s = (ZSCodeStatementOnEvent *)self.codeLine.statement;
    [self.eventButton setTitle:s.eventName forState:UIControlStateNormal];
}

- (IBAction)eventButtonTapped:(id)sender {
    ZSCodeEditorEventOptionsTableViewController *controller = [[ZSCodeEditorEventOptionsTableViewController alloc] init];
    
    controller.didSelectEventBlock = ^(NSString *event) {
        ((ZSCodeStatementOnEvent *)self.codeLine.statement).eventName = event;
        [self updateCellContents];
        [self.popover dismissPopoverAnimated:YES];
    };
    
    [self presentPopoverWithViewController:controller
                                    inView:sender];
}

@end
