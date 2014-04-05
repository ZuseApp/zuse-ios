#import "ZS_VariableChooserCollectionViewController.h"
#import <MTBlockAlertView/MTBlockAlertView.h>

@interface ZS_VariableChooserCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel* label;
@end

@implementation ZS_VariableChooserCollectionViewCell

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

@implementation ZS_VariableChooserCollectionViewController

- (UICollectionView*) collectionView
{
    UICollectionView *collectionView =[[UICollectionView alloc] initWithFrame: CGRectZero
                                                         collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
    [collectionView registerClass: ZS_VariableChooserCollectionViewCell.class
       forCellWithReuseIdentifier: NSStringFromClass([ZS_VariableChooserCollectionViewCell class])];
    
    collectionView.userInteractionEnabled = YES;
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    return collectionView;
}
# pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.variables.count + 1;
}
- (UICollectionViewCell* )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZS_VariableChooserCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([ZS_VariableChooserCollectionViewCell class])
                                              forIndexPath: indexPath];
    cell.label.text = indexPath.row ? self.variables[indexPath.row - 1] : @"+";
    return cell;
}
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) // add new variable name label touched
    {
        MTBlockAlertView *alertView =
        [[MTBlockAlertView alloc] initWithTitle: @"Create New Variable Name"
                                        message: @"Please, enter a variable name"
                              completionHanlder: ^(UIAlertView *alertView, NSInteger buttonIndex)
        {
             self.json[@"set"][0] = [alertView textFieldAtIndex:0].text;
             [self.codeEditorViewController reloadFromJson];
             [self.toolboxView hideAnimated:YES];
         }
         cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
    else
    {
        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
        NSString* variableName = ((UILabel*)cell.contentView.subviews.firstObject).text;
        self.json[@"set"][0] = variableName;
        [self.codeEditorViewController reloadFromJson];
        [self.toolboxView hideAnimated:YES];
    }
}
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *variableName = indexPath.row ? self.variables[indexPath.row - 1] : @"+";
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
