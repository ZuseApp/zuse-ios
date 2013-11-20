#import <UIKit/UIKit.h>

@interface ZSCodeEditorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)processJSON:(NSDictionary *)json;

@end
