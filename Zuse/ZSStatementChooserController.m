#import "ZSStatementChooserController.h"
#import "ZS_StatementView.h"
#import "ZSStatementCell.h"

@interface ZSStatementChooserController ()

@end

@implementation ZSStatementChooserController

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZSStatementCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    if (row == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.6 green:0.36 blue:0.38 alpha:1];
        cell.nameView.text = @"on event";
        [cell.statementView addNameLabelWithText:@"  ON EVENT"];
        [cell.statementView addArgumentLabelWithText:@"#event name" touchBlock:nil];
    }
    else if (row == 1)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.62 green:0.48 blue:0.38 alpha:1];
        cell.nameView.text = @"trigger event";
        [cell.statementView addNameLabelWithText:@"  TRIGGER EVENT"];
        [cell.statementView addArgumentLabelWithText:@"#event name" touchBlock:nil];
    }
    else if (row == 2)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.21 green:0.38 blue:0.37 alpha:1];
        cell.nameView.text = @"if";
        [cell.statementView addNameLabelWithText:@"  IF"];
        [cell.statementView addArgumentLabelWithText:@"#expression" touchBlock:nil];
    }
    else if (row == 3)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.34 green:0.51 blue:0.31 alpha:1];
        cell.nameView.text = @"set";
        [cell.statementView addNameLabelWithText:@"  SET"];
        [cell.statementView addArgumentLabelWithText:@"#name" touchBlock:nil];
        [cell.statementView addNameLabelWithText:@"TO"];
        [cell.statementView addArgumentLabelWithText:@"#value" touchBlock:nil];
    }
    else if (row == 4)
    {
        cell.backgroundColor = [UIColor colorWithRed:0.24 green:0.51 blue:0.48 alpha:1];
        cell.nameView.text = @"move";
        [cell.statementView addNameLabelWithText:@"  MOVE ("];
        [cell.statementView addArgumentLabelWithText:@"#var" touchBlock:nil];
        [cell.statementView addNameLabelWithText:@","];
        [cell.statementView addArgumentLabelWithText:@"#var" touchBlock:nil];
        [cell.statementView addNameLabelWithText:@")"];
    }
    
    cell.singleTapped = ^{
        if (_singleTapped) {
            _singleTapped(_returnJson, row);
        }
    };
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger row = indexPath.row;
    NSString *statementName = nil;
    
    if (row == 0) {
        statementName = @"on event";
    }
    else if (row == 1) {
        statementName = @"trigger event";
    }
    else if (row == 2) {
        statementName = @"if";
    }
    else if (row == 3) {
        statementName = @"set";
    }
    else if (row == 4) {
        statementName = @"move";
    }

    CGSize textSize = [statementName sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    return CGSizeMake(MAX(52, textSize.width + 10), textSize.height + 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}



@end
