#import <Foundation/Foundation.h>

@interface ZSStatementChooserController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (copy, nonatomic) void(^singleTapped)(NSMutableArray *returnJson, NSInteger statementIndex);
@property (strong, nonatomic) NSMutableArray *returnJson;

@end
