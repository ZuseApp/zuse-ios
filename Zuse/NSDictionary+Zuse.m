//
//  NSDictionary+Zuse.m
//  Zuse
//
//  Created by Parker Wightman on 12/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "NSDictionary+Zuse.h"
#import <BlocksKit/BlocksKit.h>

@implementation NSDictionary (Zuse)

- (NSDictionary *)deepCopy {
    NSDictionary *newDict = [self copyWithZone:NULL];
    
    newDict = [newDict map:^id(id key, id obj) {
        if ([obj respondsToSelector:@selector(deepCopy)]) {
            return [obj deepCopy];
        } else {
            return obj;
        }
    }];
    
    return newDict;
}

- (NSMutableDictionary *)deepMutableCopy {
    NSMutableDictionary *newDict = [self mutableCopyWithZone:NULL];
    
    newDict = [[newDict map:^id(id key, id obj) {
        if ([obj respondsToSelector:@selector(deepMutableCopy)]) {
            return [obj deepMutableCopy];
        } else {
            return obj;
        }
    }] mutableCopy];
    
    return newDict;
}

@end
