#import <UIKit/UIKit.h>

@interface ZS_CodeEditorViewController : UIViewController
@property (strong, nonatomic) NSMutableDictionary* json;
- (void) reloadFromJson;
@end
