#import <Foundation/Foundation.h>
#import "CMPopTipView.h"
#import "ZSOverlayView.h"

extern NSString * const ZSTutorialBroadcastPopupDismissed;

@interface ZSTutorial : NSObject <CMPopTipViewDelegate>

@property (nonatomic, strong) ZSOverlayView *overlayView;
@property (nonatomic, strong) NSArray *allowedGestures;
@property (nonatomic, assign, getter=isActive) BOOL active;

+ (ZSTutorial*)sharedTutorial;

- (void)presentWithCompletion:(void(^)())completion;
- (void)broadcastEvent:(NSString*)event;
- (void)addActionWithText:(NSString*)text forEvent:(NSString*)event allowedGestures:(NSArray*)allowedGestures activeRegion:(CGRect)activeRegion setup:(void(^)())setup completion:(void(^)())completion;
- (void)saveObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (id)getObjectForKey:(id <NSCopying>)aKey;
- (void)removeObjectForKey:(id <NSCopying>)aKey;
- (void)hideMessage;

@end