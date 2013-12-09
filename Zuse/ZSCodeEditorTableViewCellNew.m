#import "ZSCodeEditorTableViewCellNew.h"
#import "ZSCodeStatementNew.h"
#import "ZSCodeEditorStatementOptionsTableViewController.h"

@interface ZSCodeEditorTableViewCellNew()

@property (weak, nonatomic) IBOutlet UIButton *button;

- (IBAction)buttonTapped:(id)sender;

@end

@implementation ZSCodeEditorTableViewCellNew

- (void) updateCellContents
{
    ZSCodeStatementType type = ((ZSCodeStatementNew *)self.codeLine.statement).parentCodeStatementType;
    
    // Change the image of the button
    switch (type)
    {
        case ZSCodeStatementTypeOnEvent:
            self.button.imageView.image = [UIImage imageNamed:@"plus event"];
            break;
        case ZSCodeStatementTypeIf:
            self.button.imageView.image = [UIImage imageNamed:@"plus if"];
            break;
        default:
            self.button.imageView.image = [UIImage imageNamed:@"plus"];
            break;
    }
}

- (IBAction)buttonTapped:(id)sender
{
    ZSCodeEditorStatementOptionsTableViewController *controller = [[ZSCodeEditorStatementOptionsTableViewController alloc]init];
    
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
