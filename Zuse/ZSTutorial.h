#import <Foundation/Foundation.h>
#import "CMPopTipView.h"

@interface ZSTutorial : NSObject <CMPopTipViewDelegate>

-(void)present;
-(void)broadcastEvent:(NSString*)event;
-(void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer forKey:(NSString*)key;
-(void)addActionWithText:(NSString*)text forEvent:(NSString*)event allowedGestures:(NSArray*)allowedGestures activeRegion:(CGRect)activeRegion completion:(void(^)())completion;

@end
