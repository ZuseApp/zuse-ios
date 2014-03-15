#import <Foundation/Foundation.h>

@interface ZSGeneratorController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) void(^longPressBegan)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressChanged)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressEnded)(UILongPressGestureRecognizer *longPressGestureRecognizer);

@end
