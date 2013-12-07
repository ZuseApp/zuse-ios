#import <UIKit/UIKit.h>
#import "ZSCodeStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeStatementOptionsTableViewController : UITableViewController

@property (copy, nonatomic) void (^didSelectStatementBlock)(ZSCodeStatementType s);

@end
