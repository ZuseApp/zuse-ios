#import <UIKit/UIKit.h>

@interface ZS_ExpressionViewController : UIViewController
@property (strong, nonatomic) NSObject* json;
@property (copy, nonatomic) void(^didFinish)(NSObject* json);
@end
