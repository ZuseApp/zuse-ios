#import <UIKit/UIKit.h>
#import "ZS_StatementView.h"

@interface ZSStatementCell : UICollectionViewCell

@property (copy, nonatomic) void(^singleTapped)();
@property (strong, nonatomic) UILabel *nameView;
@property (strong, nonatomic) ZS_StatementView *statementView;

@end
