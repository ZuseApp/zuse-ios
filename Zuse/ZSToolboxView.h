#import <UIKit/UIKit.h>

@interface ZSToolboxView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) void(^hidView)();

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (UICollectionView*)collectionViewByIndex:(NSInteger)index;
- (void)addCollectionView:(UICollectionView*)collectionView title:(NSString*)title;

@end
