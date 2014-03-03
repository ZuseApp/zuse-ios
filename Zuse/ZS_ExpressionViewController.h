#import <UIKit/UIKit.h>

@interface ZS_ExpressionViewController : UIViewController
@property (strong, nonatomic) NSObject* json;
@property (copy, nonatomic) void(^didFinish)(NSObject* json);
@property (strong, nonatomic) NSArray* variableNames;
@end
