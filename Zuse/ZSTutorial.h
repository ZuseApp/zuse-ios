#import <Foundation/Foundation.h>
#import "CMPopTipView.h"

@interface ZSTutorial : NSObject <CMPopTipViewDelegate>

-(void)bindToView:(UIView*)view;
-(void)show;
-(void)hide;
-(void)refresh;
-(void)touchActionOn:(UIView *)view withText:(NSString*)text completion:(void(^)())completion;

@end
