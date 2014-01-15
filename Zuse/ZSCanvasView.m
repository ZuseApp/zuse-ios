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
        _grid = [[ZSGrid alloc] init];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    // CGContextSetLineWidth(context, 3.0);
    // CGContextSetLineCap(context, kCGLineCapRound);
    // CGContextSetLineJoin(context, kCGLineJoinRound);
    // CGContextMoveToPoint(context, 5, 5);
    // CGContextAddLineToPoint(context, 45, 43);
    // CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
    
    // for (NSUInteger i = 0; i < _grid.dimensions.)
}

@end
