#import <Foundation/Foundation.h>
#import "CMPopTipView.h"
#import "ZSOverlayView.h"

@interface ZSTutorial : NSObject

@property (nonatomic, strong) ZSOverlayView *overlayView;
@property (nonatomic, strong) UIView* toolTipOverrideView;
@property (nonatomic, assign, getter=isActive) BOOL active;

- (void)present;
- (void)broadcastEvent:(NSString*)event;
- (void)addActionWithText:(NSString*)text forEvent:(NSString*)event activeRegion:(CGRect)activeRegion setup:(void(^)())setup completion:(void(^)())completion;

- (void)hideMessage;

@end
