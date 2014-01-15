//
//  ZSGrid.m
//  Zuse
//
//  Created by Michael Hogenson on 1/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSGrid.h"

@implementation ZSGrid

- (CGPoint)adjustedPointForPoint:(CGPoint)point {
    CGFloat screenWidth = _screenSize.width;
    CGFloat screenHeight = _screenSize.height;
    
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
