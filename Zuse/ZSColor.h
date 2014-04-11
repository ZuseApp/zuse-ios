//
//  ZSColor.h
//  Zuse
//
//  Created by Parker Wightman on 4/10/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSColor : NSObject

+ (UIColor *)colorForDSLItem:(NSString *)DSLItem;
+ (UIColor*)lightenColor:(UIColor *)color withValue:(CGFloat)value;
+ (UIColor*)darkenColor:(UIColor *)color withValue:(CGFloat)value;

@end
