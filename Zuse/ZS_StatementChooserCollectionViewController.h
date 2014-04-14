#import <Foundation/Foundation.h>
#import "ZS_CodeEditorViewController.h"
#import "ZSToolboxView.h"

@interface ZS_StatementChooserCollectionViewController : NSObject  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) ZS_CodeEditorViewController* codeEditorViewController;
@property (weak, nonatomic) ZSToolboxView* toolboxView;
@property (weak, nonatomic) NSMutableArray* jsonCodeBody;
@property (nonatomic) NSInteger newStatementIndex; // where to insert a new statement in jsonCodeBody
-(UICollectionView*) collectionView;
@end
