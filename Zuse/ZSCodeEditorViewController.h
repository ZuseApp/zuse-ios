#import <UIKit/UIKit.h>

@interface ZSCodeEditorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)processJSON:(NSDictionary *)json;

@end
