#import "ZSCodeEditorSetStatementTableViewCell.h"
#import "ZSCodeSetStatement.h"

@interface ZSCodeEditorSetStatementTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *varNameButton;
@property (weak, nonatomic) IBOutlet UIButton *varValueButton;

@end

@implementation ZSCodeEditorSetStatementTableViewCell

#pragma mark - ZSCodeEditorSetStatementTableViewCell

- (void)setCodeLine:(ZSCodeLine *)codeLine
{
    super.codeLine = codeLine;
    
    ZSCodeSetStatement *s = (ZSCodeSetStatement *)self.codeLine.statement;
    [self.varNameButton setTitle:s.variableName forState:UIControlStateNormal];
    [self.varValueButton setTitle:s.variableValueStringValue forState:UIControlStateNormal];
}

@end
