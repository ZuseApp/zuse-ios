#import <UIKit/UIKit.h>

@interface ZSCodeEditorPopoverTableViewController : UITableViewController

@property (copy, nonatomic) void (^didSelectRowBlock)(NSInteger row);

- (id)initWithStyle:(UITableViewStyle)style
         dataSource:(id<UITableViewDataSource>) dataSource;

@end
