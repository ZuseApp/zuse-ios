#import "ZSCodeEditorIfStatementTableViewCell.h"
#import "ZSCodeIfStatement.h"

@interface ZSCodeEditorIfStatementTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *boolExpButton;

@end

@implementation ZSCodeEditorIfStatementTableViewCell

- (void)updateCellContents
{
    ZSCodeIfStatement *s = (ZSCodeIfStatement *)self.codeLine.statement;
    [self.boolExpButton setTitle:s.boolExp.stringValue forState:UIControlStateNormal];
}

@end
