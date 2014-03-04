//
//  UIImageView+Zuse.m
//  Zuse
//
//  Created by Parker Wightman on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "UIImageView+Zuse.h"

@implementation UIImageView (Zuse)

- (CGRect)imageFrame {
    UIImageView *iv = self;
    CGSize imageSize = iv.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), roundf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    
    return imageFrame;
}

@end
