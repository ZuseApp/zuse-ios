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
        _grid.size = rect.size;
        for (NSUInteger row = 0; row < _grid.dimensions.height; row++) {
            for (NSUInteger column = 0; column < _grid.dimensions.width; column++) {
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
                CGContextSetLineWidth(context, 0.1f);
                CGContextAddRect(context, [_grid frameForPosition:CGPointMake(column, row)]);
                CGContextStrokePath(context);
            }
        }
    }
}

@end
