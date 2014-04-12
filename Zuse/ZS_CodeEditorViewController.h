#import <UIKit/UIKit.h>
#import "ZS_StatementView.h"

@interface ZS_CodeEditorViewController : UIViewController <ZS_StatementViewDelegate>
@property (strong, nonatomic) NSMutableArray *codeItems;
@property (strong, nonatomic) NSDictionary *initialProperties; // for variable scoping
- (void) reloadFromJson;
- (void) scrollToRight;
@end
