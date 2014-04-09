#import <UIKit/UIKit.h>
#import "ZS_StatementView.h"

@interface ZS_CodeEditorViewController : UIViewController <ZS_StatementViewDelegate>
@property (strong, nonatomic) NSMutableDictionary* json;
- (void) reloadFromJson;
- (void) scrollToRight;
@end
