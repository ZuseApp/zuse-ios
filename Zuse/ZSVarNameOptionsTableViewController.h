#import <UIKit/UIKit.h>

@interface ZSVarNameOptionsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *varNames;
@property (copy, nonatomic) void (^didSelectValueBlock)(id value);

@end
