#import "ZSCodeEditorNewStatementTableViewCell.h"
#import "ZSCodeNewStatement.h"
#import "ZSCodeStatementOptionsTableViewController.h"

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
    ZSCodeStatementOptionsTableViewController *controller = [[ZSCodeStatementOptionsTableViewController alloc]init];
    
    controller.didSelectStatementBlock = ^(ZSCodeStatementType s)
    {
        [self.codeLine.statement.parentSuite addEmptyStatementWithType:s];
        [self.popover dismissPopoverAnimated:YES];
        [self.viewController.tableView reloadData];
    };
    [self presentPopoverWithViewController:controller
                                    inView:sender];
}
@end
