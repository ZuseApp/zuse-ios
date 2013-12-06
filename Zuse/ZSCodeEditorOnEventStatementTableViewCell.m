#import "ZSCodeEditorOnEventStatementTableViewCell.h"
#import "ZSCodeOnEventStatement.h"

@interface ZSCodeEditorOnEventStatementTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *eventButton;

@end

@implementation ZSCodeEditorOnEventStatementTableViewCell

- (void)updateCellContents
{
    ZSCodeOnEventStatement *s = (ZSCodeOnEventStatement *)self.codeLine.statement;
    [self.eventButton setTitle:s.eventName forState:UIControlStateNormal];
}

@end
