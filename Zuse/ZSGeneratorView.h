#import <UIKit/UIKit.h>
#import "ZSSpriteView.h"

@interface ZSGeneratorView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) void(^singleTapped)(ZSSpriteView *spriteView);
@property (strong, nonatomic) void(^generatorRemoved)(ZSSpriteView *spriteView);
@property (strong, nonatomic) void(^addGeneratorRequested)();
- (void)addGeneratorFromJSON:(NSMutableDictionary*)generatorJSON;

@end
