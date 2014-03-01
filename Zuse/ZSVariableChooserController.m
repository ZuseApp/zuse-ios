//
//  ZSVariableChooser.m
//  Zuse
//
//  Created by Vladimir on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSVariableChooserController.h"
#import "ZSStatementCell.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@implementation ZSVariableChooserController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%lu", (unsigned long)_variables.count);
    return _variables.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZSStatementCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    NSInteger row = indexPath.row;
 
    cell.backgroundColor = [UIColor colorWithRed:0.6 green:0.36 blue:0.38 alpha:1];
    if (row == 0) {
        cell.nameView.text = @"+";
    }
    else {
        
        cell.nameView.text = ([_variables allObjects])[row - 1];
    }
    
    NSString *variableName = cell.nameView.text;
    cell.singleTapped = ^{
        if (_singleTapped) {
            _singleTapped(variableName);
        }
    };
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    NSString *variableName;
    CGSize textSize;
    if (row == 0) {
        textSize = [@"+" sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    }
    else {
        variableName = ([_variables allObjects])[row - 1];
        textSize = [variableName sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    }
    return CGSizeMake(MAX(52, textSize.width + 10), textSize.height + 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


@end
