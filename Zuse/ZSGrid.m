//
//  ZSGrid.m
//  Zuse
//
//  Created by Michael Hogenson on 1/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSGrid.h"

@implementation ZSGrid

- (id)init {
    self = [super init];
    if (self) {
        _dimensions = CGSizeMake(0, 0);
    }
    return self;
}

- (CGRect)frameForPosition:(CGPoint)position {
    CGFloat screenWidth = _size.width;
    CGFloat screenHeight = _size.height;
    
    CGFloat columnCount = _dimensions.width;
    CGFloat rowCount = _dimensions.height;
    
    CGFloat columnWidth = screenWidth / columnCount;
    CGFloat rowHeight = screenHeight / rowCount;
    
    CGFloat x = position.x;
    CGFloat y = position.y;
    
    CGPoint framePoint = CGPointMake(x * columnWidth, y * rowHeight);
    CGSize frameSize = CGSizeMake(columnWidth, rowHeight);
    
    return CGRectMake(framePoint.x, framePoint.y, frameSize.width, frameSize.height);
}

- (CGPoint)adjustedPointForPoint:(CGPoint)point {
    CGFloat screenWidth = _size.width;
    CGFloat screenHeight = _size.height;
    
    CGFloat columnCount = _dimensions.width;
    CGFloat rowCount = _dimensions.height;
    
    CGFloat columnWidth = screenWidth / columnCount;
    CGFloat rowHeight = screenHeight / rowCount;

    CGFloat x = point.x;
    CGFloat y = point.y;
    
    NSInteger truncatedX = x / columnWidth;
    NSInteger truncatedY = y / rowHeight;
    
    return CGPointMake(truncatedX * columnWidth, truncatedY * rowHeight);
}

@end
