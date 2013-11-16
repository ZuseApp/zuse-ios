#import <UIKit/UIKit.h>

@interface ZSCodeEditorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)processJSON:(NSMutableArray *)json;

@end
