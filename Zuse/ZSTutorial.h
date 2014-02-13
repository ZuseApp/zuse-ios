#import <Foundation/Foundation.h>
#import "CMPopTipView.h"

@interface ZSTutorial : NSObject <CMPopTipViewDelegate>

-(void)bindToView:(UIView*)view;
-(void)show;
-(void)hide;
-(void)touchActionOn:(UIView *)view withText:(NSString*)text completetion:(void(^)())completion;

@end
