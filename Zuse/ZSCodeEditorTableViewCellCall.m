#import "ZSCodeEditorTableViewCellCall.h"
#import "ZSCodeStatementCall.h"
@interface ZSCodeEditorTableViewCellCall()

@property (weak, nonatomic) IBOutlet UILabel *methodName;
@property (weak, nonatomic) IBOutlet UIButton *param1;
@property (weak, nonatomic) IBOutlet UIButton *param2;

@end

@implementation ZSCodeEditorTableViewCellCall

- (void)updateCellContents
{
    ZSCodeStatementCall *s = (ZSCodeStatementCall *)self.codeLine.statement;
    self.methodName.text = s.methodName;
    [self.param1 setTitle:[s.params[0] stringValue] forState:UIControlStateNormal];
    [self.param2 setTitle:[s.params[1] stringValue] forState:UIControlStateNormal];
}


@end
