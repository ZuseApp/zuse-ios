#import "ZSCodeEditorNewStatementTableViewCell.h"
#import "ZSCodeNewStatement.h"

@interface ZSCodeEditorNewStatementTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *button;

- (IBAction)buttonTapped:(id)sender;

@end

@implementation ZSCodeEditorNewStatementTableViewCell

- (void) updateCellContents
{
    ZSCodeNewStatementType type = ((ZSCodeNewStatement *)self.codeLine.statement).type;
    
    // Change the image of the button
    switch (type)
    {
        case ZSCodeNewStatementInsideOnEvent:
            
            self.button.imageView.image = [UIImage imageNamed:@"plus event"];
            break;
            
        case ZSCodeNewStatementInsideIf:
            
            self.button.imageView.image = [UIImage imageNamed:@"plus if"];
            break;
            
        default:
            
            self.button.imageView.image = [UIImage imageNamed:@"plus"];
            break;
    }
}

- (IBAction)buttonTapped:(id)sender
{
    [self.codeLine.statement.parentSuite addEmptySetStatement];
    [self.controller.tableView reloadData];
    
}
@end
