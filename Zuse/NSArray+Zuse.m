//
//  NSArray+Zuse.m
//  Zuse
//
//  Created by Parker Wightman on 12/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "NSArray+Zuse.h"
#import "BlocksKit.h"

@implementation NSArray (Zuse)

- (NSArray *)deepCopy {
    NSArray *newArray = [self copyWithZone:NULL];
    
    newArray = [newArray map:^id(id obj) {
        if ([obj respondsToSelector:@selector(deepCopy)]) {
            return [obj deepCopy];
        } else {
            return obj;
        }
    }];
    
    return newArray;
}

- (NSMutableArray *)deepMutableCopy {
    NSMutableArray *newArray = [self mutableCopyWithZone:NULL];
    
    newArray = [[newArray map:^id(id obj) {
        if ([obj respondsToSelector:@selector(deepMutableCopy)]) {
            return [obj deepMutableCopy];
        } else {
            return obj;
        }
    }] mutableCopy];
    
    return newArray;
}

@end
