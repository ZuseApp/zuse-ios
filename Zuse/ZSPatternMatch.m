//
//  ZSPatternMatch.m
//  Zuse
//
//  Created by Parker Wightman on 2/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSPatternMatch.h"

@implementation ZSPatternMatch

+ (NSArray *) normalizedValuesForCodeSuite:(NSArray *)code {
    NSDictionary *(^transformBlock)(NSDictionary *) = ^NSDictionary *(NSDictionary *line) {
        NSString *key = line.allKeys.firstObject;
        
        if ([key isEqualToString:@"get"]) {
            return [self normalizedGet:line[key]];
        }
        else if ([key isEqualToString:@"set"]) {
            return [self normalizedSet:line[key]];
        }
        return nil;
    };
    
    return [self codeLines:code transformedByBlock:transformBlock];
}

+ (NSArray *) codeLines:(NSArray *)lines transformedByBlock:(NSDictionary *(^)(NSDictionary *))transformBlock {
    NSMutableArray *newSuite = [NSMutableArray array];
    
    for (NSDictionary *line in lines) {
        NSDictionary *result = transformBlock(line);
        if (result)
            [newSuite addObject:result];
    }
    
    return newSuite;
}

+ (BOOL) isPlaceholderValue:(NSString *)value {
    return [value hasPrefix:@"#"];
}

+ (NSDictionary *)normalizedGet:(NSString *)varName {
    if ([self isPlaceholderValue:varName]) {
        return nil;
    } else {
        return @{ @"get": varName };
    }
}

+ (NSDictionary *)normalizedSet:(NSArray *)values {
    if ([self isPlaceholderValue:values[0]] || [self isPlaceholderValue:values[1]]) {
        return nil;
    } else {
        return @{ @"set": values };
    }
}

@end
