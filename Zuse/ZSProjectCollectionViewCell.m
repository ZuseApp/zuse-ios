//
//  ZSProjectCollectionViewCell.m
//  Zuse
//
//  Created by Parker Wightman on 2/27/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSProjectCollectionViewCell.h"

@interface ZSProjectCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *screenshotView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ZSProjectCollectionViewCell

- (void)layoutSubviews {
    self.nameLabel.text = self.projectTitle;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.screenshotView.image = self.screenshot;
    self.screenshotView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
