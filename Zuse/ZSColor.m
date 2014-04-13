//
//  ZSColor.m
//  Zuse
//
//  Created by Parker Wightman on 4/10/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import "ZSColor.h"

@implementation ZSColor

+ (UIColor *)colorForDSLItem:(NSString *)DSLItem {
    NSDictionary *mapping = @{
        @"if": [UIColor colorWithRed:0.99 green:0.48 blue:0.51 alpha:1],
        @"every": [UIColor colorWithRed:0.71 green:0.74 blue:0.36 alpha:1],
        @"after": [UIColor colorWithRed:0.71 green:0.74 blue:0.36 alpha:1],
        @"in": [UIColor colorWithRed:0.71 green:0.74 blue:0.36 alpha:1],
        @"call": [UIColor zuseBlue],
        @"on_event": [UIColor colorWithRed:0.76 green:0.53 blue:0.83 alpha:1],
        @"trigger_event": [UIColor colorWithRed:0.6 green:0.57 blue:0.85 alpha:1],
        @"set": [UIColor colorWithRed:1.000 green:0.665 blue:0.426 alpha:1.000]
    };

    return (mapping[DSLItem] ? [self lightenColor:mapping[DSLItem] withValue:0.1] : [UIColor whiteColor]);
}

+ (UIColor*)lightenColor:(UIColor *)color withValue:(CGFloat)value
{
    size_t totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(color.CGColor);
    CGFloat newComponents[4];
    
    if(isGreyscale)
    {
        newComponents[0] = oldComponents[0] + value > 1.0 ? 1.0 : oldComponents[0] + value;
        newComponents[1] = oldComponents[0] + value > 1.0 ? 1.0 : oldComponents[0] + value;
        newComponents[2] = oldComponents[0] + value > 1.0 ? 1.0 : oldComponents[0] + value;
        newComponents[3] = oldComponents[1];
    }
    else
    {
        newComponents[0] = oldComponents[0] + value > 1.0 ? 1.0 : oldComponents[0] + value;
        newComponents[1] = oldComponents[1] + value > 1.0 ? 1.0 : oldComponents[1] + value;
        newComponents[2] = oldComponents[2] + value > 1.0 ? 1.0 : oldComponents[2] + value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}

+ (UIColor*)darkenColor:(UIColor *)color withValue:(CGFloat)value
{
    size_t totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(color.CGColor);
    CGFloat newComponents[4];
    
    if(isGreyscale)
    {
        newComponents[0] = oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value;
        newComponents[1] = oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value;
        newComponents[2] = oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value;
        newComponents[3] = oldComponents[1];
    }
    else
    {
        newComponents[0] = oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value;
        newComponents[1] = oldComponents[1] - value < 0.0 ? 0.0 : oldComponents[1] - value;
        newComponents[2] = oldComponents[2] - value < 0.0 ? 0.0 : oldComponents[2] - value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}

@end
