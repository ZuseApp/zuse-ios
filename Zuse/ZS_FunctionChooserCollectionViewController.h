#import <Foundation/Foundation.h>
#import "ZSToolboxView.h"

@interface ZS_FunctionChooserCollectionViewController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) ZSToolboxView* toolboxView;
@property (copy, nonatomic) void(^didFinish)(NSMutableDictionary* function);
-(UICollectionView*) collectionView;
@end
