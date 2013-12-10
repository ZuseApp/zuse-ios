#import <UIKit/UIKit.h>

typedef void (^ZSEventSelectionBlock)(NSString *value);

@interface ZSCodeEditorEventOptionsTableViewController : UITableViewController

@property (copy, nonatomic) ZSEventSelectionBlock didSelectEventBlock;

@end
