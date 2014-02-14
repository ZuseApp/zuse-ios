#import <Foundation/Foundation.h>
#import "CMPopTipView.h"

@interface ZSTutorial : NSObject <CMPopTipViewDelegate>

-(void)present;
-(void)addTouchActionWithText:(NSString*)text setup:(void(^)())setup completion:(void(^)())completion;
-(void)addRightEdgeSwipeActionWithText:(NSString*)text setup:(void(^)())setup completion:(void(^)())completion;

@end
