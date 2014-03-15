//
//  ZSProjectCollectionViewCell.h
//  Zuse
//
//  Created by Parker Wightman on 2/27/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSProjectCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *screenshot;
@property (strong, nonatomic) NSString *projectTitle;
@property (weak, nonatomic, readonly) UIImageView *screenshotView;

@end
