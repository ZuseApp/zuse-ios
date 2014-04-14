#import <Foundation/Foundation.h>
//#import "ZS_CodeEditorViewController.h"
#import "ZSToolboxView.h"

@interface ZS_ExpressionVariableChooserCollectionViewController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *variables;
@property (weak, nonatomic) ZSToolboxView* toolboxView;
@property (copy, nonatomic) void(^didFinish)(NSString* variableName);
-(UICollectionView*) collectionView;
@end
