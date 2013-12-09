#import <UIKit/UIKit.h>
#import "ZSCodeStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeEditorStatementOptionsTableViewController : UITableViewController

@property (copy, nonatomic) void (^didSelectStatementBlock)(ZSCodeStatementType s);

@end
