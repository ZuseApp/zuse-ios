#import "ZSCodeEditorTableViewCellIf.h"
#import "ZSCodeStatementIf.h"

@interface ZSCodeEditorTableViewCellIf()

@property (weak, nonatomic) IBOutlet UIButton *boolExpButton;

@end

@implementation ZSCodeEditorTableViewCellIf

- (void)updateCellContents
{
    ZSCodeStatementIf *s = (ZSCodeStatementIf *)self.codeLine.statement;
    [self.boolExpButton setTitle:s.boolExp.stringValue forState:UIControlStateNormal];
}

@end
