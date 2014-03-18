#import <UIKit/UIKit.h>

@interface ZSSpriteView : UIView <UIGestureRecognizerDelegate>

- (BOOL)setContentFromJSON:(NSDictionary*)spriteJSON;
- (BOOL)setThumbnailFromJSON:(NSMutableDictionary*)spriteJSON;
- (void)reloadContent;

@property (strong, nonatomic) void(^singleTapped)();
@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer);
@property (strong, nonatomic) void(^longPressBegan)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressChanged)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressEnded)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^cut)(ZSSpriteView *sprite);
@property (strong, nonatomic) void(^copy)(ZSSpriteView *sprite);
@property (strong, nonatomic) void(^paste)();
@property (strong, nonatomic) void(^delete)(ZSSpriteView *sprite);
@property (nonatomic, strong) NSMutableDictionary *spriteJSON;
@property (nonatomic, strong) UIView *content;

@end
