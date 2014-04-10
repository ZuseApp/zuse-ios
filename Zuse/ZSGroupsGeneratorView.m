//
//  ZSGroupsGeneratorView.m
//  Zuse
//
//  Created by Parker Wightman on 4/5/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import "ZSGroupsGeneratorView.h"
#import "ZSToolboxCell.h"
#import "ZSProjectJSONKeys.h"

@implementation ZSGroupsGeneratorView
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.delegate = self;
    self.dataSource = self;
    self.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    [self registerClass:ZSToolboxCell.class forCellWithReuseIdentifier:@"cellID"];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.generators.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    ZSToolboxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];

    NSMutableDictionary *json = [self.generators[row] mutableCopy];
    [cell.spriteView setThumbnailFromJSON:json];
    cell.spriteView.contentMode = UIViewContentModeScaleAspectFit;

    if (self.isSpriteSelected(json)) {
        cell.spriteView.alpha = 1.0;
    } else {
        cell.spriteView.alpha = 0.2;
    }

    WeakSelf
    cell.spriteView.singleTapped = ^ {
        weakSelf.didTapSprite(self.generators[indexPath.row]);
        [collectionView reloadData];
    };

    [cell.spriteName setText:json[@"name"]];
    cell.spriteName.textColor = [UIColor blackColor];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(73, 57);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}
 
@end
