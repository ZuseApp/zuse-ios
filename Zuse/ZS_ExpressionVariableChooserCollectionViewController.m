#import "ZS_ExpressionVariableChooserCollectionViewController.h"

@interface ZS_ExpresssionVariableChooserCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel* label;
@end

@implementation ZS_ExpresssionVariableChooserCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Cell appearance
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor colorWithRed:0.6 green:0.36 blue:0.38 alpha:1];
        
        // Label
        self.label = [[UILabel alloc] initWithFrame: self.bounds];
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
    }
    return self;
}
@end

@implementation ZS_ExpressionVariableChooserCollectionViewController

- (UICollectionView*) collectionView
{
    UICollectionView *collectionView =[[UICollectionView alloc] initWithFrame: CGRectZero
                                                         collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
    [collectionView registerClass: ZS_ExpresssionVariableChooserCollectionViewCell.class
       forCellWithReuseIdentifier: NSStringFromClass([ZS_ExpresssionVariableChooserCollectionViewCell class])];
    
    collectionView.userInteractionEnabled = YES;
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    return collectionView;
}
# pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.variables.count;
}
- (UICollectionViewCell* )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZS_ExpresssionVariableChooserCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([ZS_ExpresssionVariableChooserCollectionViewCell class])
                                              forIndexPath: indexPath];
    cell.label.text = self.variables[indexPath.row];
    return cell;
}
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.toolboxView hideAnimated:YES];
    if(self.didFinish)
    {
        NSString *variableName = self.variables[indexPath.row];
        self.didFinish(variableName);
    }
}
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *variableName = self.variables[indexPath.row];
    CGSize textSize = [variableName sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    return CGSizeMake(MAX(52, textSize.width + 10), textSize.height + 10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
@end
