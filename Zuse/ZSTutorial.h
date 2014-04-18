#import <Foundation/Foundation.h>
#import "CMPopTipView.h"
#import "ZSOverlayView.h"

extern NSString * const ZSTutorialBroadcastEventComplete;
extern NSString * const ZSTutorialBroadcastExitTutorial;
extern NSString * const ZSTutorialBroadcastDebugPause;

typedef NS_ENUM(NSInteger, ZSTutorialStage) {
    ZSTutorialSetupStage,
    ZSTutorialBallCodeStage,
    ZSTutorialBallCodeStage2,
    ZSTutorialBallCollisionEvent
};

@interface ZSTutorial : NSObject <CMPopTipViewDelegate>

@property (nonatomic, strong) ZSOverlayView *overlayView;
@property (nonatomic, strong) NSArray *allowedGestures;
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, assign) ZSTutorialStage stage;

+ (ZSTutorial*)sharedTutorial;

- (void)present;
- (void)broadcastEvent:(NSString*)event;
- (void)addActionWithText:(NSString*)text forEvent:(NSString*)event allowedGestures:(NSArray*)allowedGestures activeRegion:(CGRect)activeRegion setup:(void(^)())setup completion:(void(^)())completion;
- (void)saveObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (id)getObjectForKey:(id <NSCopying>)aKey;
- (void)removeObjectForKey:(id <NSCopying>)aKey;
- (void)hideMessage;

@end