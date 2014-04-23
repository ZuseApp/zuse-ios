#import "ZS_StatementChooserCollectionViewController.h"
#import "ZS_JsonUtilities.h"
#import "ZSTutorial.h"

@interface ZS_StatementChooserCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel* label;
@end

@implementation ZS_StatementChooserCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Cell appearance
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor colorWithRed:0.6 green:0.36 blue:0.38 alpha:1];
        
        // Label
        self.label = [[UILabel alloc] initWithFrame: self.bounds];
        self.label.font = [UIFont zuseFontWithSize:16];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
    }
    return self;
}
@end

@interface ZS_StatementChooserCollectionViewController ()
@property (nonatomic, strong) NSArray* statements;
@end

@implementation ZS_StatementChooserCollectionViewController

- (void) setJsonCodeBody:(NSMutableArray *)jsonCodeBody
{
    _jsonCodeBody = jsonCodeBody;
    self.newStatementIndex = jsonCodeBody.count;
}

- (NSArray*) statements
{
    if (!_statements)
    {
        _statements = [[ZS_JsonUtilities emptyStatements] arrayByAddingObjectsFromArray:[ZS_JsonUtilities emptyMethods]];
    }
    return _statements;
}
- (UICollectionView*) collectionView
{
    UICollectionView *collectionView =[[UICollectionView alloc] initWithFrame: CGRectZero
                                                         collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
    [collectionView registerClass: ZS_StatementChooserCollectionViewCell.class
       forCellWithReuseIdentifier: NSStringFromClass([ZS_StatementChooserCollectionViewCell class])];
    
    collectionView.userInteractionEnabled = YES;
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    return collectionView;
}
# pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.statements.count;
}
- (UICollectionViewCell* )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZS_StatementChooserCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([ZS_StatementChooserCollectionViewCell class]) forIndexPath: indexPath];
    NSDictionary* statement = self.statements[indexPath.row];
    NSString* name = statement.allKeys[0];
    name = [name isEqualToString:@"call"] ? statement[name][@"method"] : name;
    cell.label.text = name;
    return cell;
}
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZS_StatementChooserCollectionViewCell *cell = (ZS_StatementChooserCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    cell.contentView.alpha = 0.2;
    [UIView animateWithDuration:0.25
                     animations:^{
                         cell.contentView.alpha = 1;
                     } completion:^(BOOL finished) {
                         //[self.jsonCodeBody addObject: self.statements[indexPath.row]];
                         [self.jsonCodeBody insertObject: self.statements[indexPath.row] atIndex:self.newStatementIndex];

                         [self.codeEditorViewController reloadFromJson];
                         [self.toolboxView hideAnimated:YES];
                         [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
                     }];
}
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* statement = self.statements[indexPath.row];
    NSString* name = statement.allKeys[0];
    name = [name isEqualToString:@"call"] ? statement[name][@"method"] : name;
    CGSize textSize = [name sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
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
