#import <UIKit/UIKit.h>
#import "ZSProject.h"

@interface ZSCanvasViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) ZSProject *project;
@property (assign, nonatomic) CGRect initialCanvasRect;
@property (copy, nonatomic) void(^didFinish)();

@end
