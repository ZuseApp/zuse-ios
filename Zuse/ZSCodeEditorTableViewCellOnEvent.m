#import "ZSCodeEditorTableViewCellOnEvent.h"
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

@end
