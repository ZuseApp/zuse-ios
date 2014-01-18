#import <UIKit/UIKit.h>

@interface ZSCodeEditorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSMutableDictionary *spriteObject;

@end
