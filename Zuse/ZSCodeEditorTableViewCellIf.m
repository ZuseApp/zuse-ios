#import "ZSCodeEditorTableViewCellIf.h"
#import "ZSCodeStatementIf.h"

@interface ZSCodeEditorTableViewCellIf()

@property (weak, nonatomic) IBOutlet UIButton *exp1;
@property (weak, nonatomic) IBOutlet UIButton *exp2;
@property (weak, nonatomic) IBOutlet UIButton *sign;

@end

@implementation ZSCodeEditorTableViewCellIf

- (void)updateCellContents
{
    ZSCodeStatementIf *s = (ZSCodeStatementIf *)self.codeLine.statement;
    
    [self.exp1 setTitle: s.boolExp.exp1stringValue forState: UIControlStateNormal];
    [self.exp2 setTitle: s.boolExp.exp2stringValue forState: UIControlStateNormal];
    [self.sign setTitle: s.boolExp.sign            forState: UIControlStateNormal];
}


@end
