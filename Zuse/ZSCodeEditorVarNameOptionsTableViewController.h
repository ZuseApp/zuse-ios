#import <UIKit/UIKit.h>

@interface ZSCodeEditorVarNameOptionsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *varNames;
@property (copy, nonatomic) void (^didSelectValueBlock)(id value);

@end
