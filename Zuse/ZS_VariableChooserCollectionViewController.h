#import <Foundation/Foundation.h>
#import "ZS_CodeEditorViewController.h"
#import "ZSToolboxView.h"

@interface ZS_VariableChooserCollectionViewController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *variables;
@property (weak, nonatomic) ZS_CodeEditorViewController* codeEditorViewController;
@property (weak, nonatomic) ZSToolboxView* toolboxView;
@property (weak, nonatomic) NSMutableDictionary* json;
-(UICollectionView*) collectionView;
@end
