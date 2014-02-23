#import <UIKit/UIKit.h>

@interface ZSToolboxView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) void(^hidView)();

- (void)setPagingEnabled:(BOOL)enabled;
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (UIView*)viewByIndex:(NSInteger)index;
- (void)addContentView:(UIView*)view title:(NSString*)title;
- (void)addButton:(UIButton*)button;

@end
