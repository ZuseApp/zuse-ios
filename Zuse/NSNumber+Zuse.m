//
//  NSNumber+coercedString.m
//  Zuse
//
//  Created by Parker Wightman on 1/28/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "NSNumber+Zuse.h"

@implementation NSNumber (Zuse)

- (NSString *)coercedString {
    return [self stringValue];
}

@end
