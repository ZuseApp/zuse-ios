//
//  ZSCanvasView.m
//  Zuse
//
//  Created by Michael Hogenson on 1/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSCanvasView.h"

@implementation ZSCanvasView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _grid = [[ZSGrid alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_grid) {
        UIColor *lineColor = [UIColor colorWithRed:0.86f green:0.86f blue:0.86f alpha:1];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
        CGContextSetLineWidth(context, 0.5f);
        
        _grid.size = rect.size;
        for (NSUInteger row = 0; row < _grid.dimensions.height; row++) {
            for (NSUInteger column = 0; column < _grid.dimensions.width; column++) {
                CGContextStrokeRect(context, [_grid frameForPosition:CGPointMake(column, row)]);
            }
        }
    }
}

@end
