//
//  ZSGroupsGeneratorView.h
//  Zuse
//
//  Created by Parker Wightman on 4/5/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSGroupsGeneratorView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) NSArray *generators;
@property (copy, nonatomic) void (^didTapSprite)(NSDictionary *sprite);
@property (copy, nonatomic) BOOL (^isSpriteSelected)(NSDictionary *sprite);

@end
