//
//  ZSCodeNormalizer.m
//  Zuse
//
//  Created by Parker Wightman on 3/22/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSCodeNormalizer.h"
#import "NSNumber+Zuse.h"
#import "NSString+Zuse.h"
#import "ZSCodeTraverser.h"
#import "BlocksKit.h"
#import "ZSCodeTransforms.h"

@implementation ZSCodeNormalizer

+ (NSDictionary *)normalizedCodeItem:(NSDictionary *)codeItem {
    NSDictionary *normalizedItem = [self codeItemByFilteringCodeWithEmptyPlaceholders:codeItem];
    return normalizedItem;
}

+ (NSDictionary *)codeItemByFilteringCodeWithEmptyPlaceholders:(NSDictionary *)codeItem {
    return [ZSCodeTraverser filter:codeItem block:^BOOL(NSDictionary *codeItem) {
        NSString *key = codeItem.allKeys.firstObject;
        
        __block BOOL valid = YES;
        
        if ([key isEqualToString:@"set"]) {
            if ([self isPlaceholderValue:codeItem[key][0]] ||
                [self isPlaceholderValue:codeItem[key][1]]) {
                valid = NO;
            }
        } else if ([key isEqualToString:@"if"]) {
            if ([self isPlaceholderValue:codeItem[key][@"test"]]) {
                valid = NO;
            }
        } else if ([key isEqualToString:@"on_event"]) {
            if ([self isPlaceholderValue:codeItem[key][@"name"]]) {
                valid = NO;
            }
        } else if ([key isEqualToString:@"trigger_event"]) {
            if ([self isPlaceholderValue:codeItem[key][@"name"]]) {
                valid = NO;
            }
        }
        
        return valid;
    }];
}

+ (BOOL)isPlaceholderValue:(id)value {
    if ([value isKindOfClass:NSString.class] &&
        [value hasPrefix:@"#"]) {
        return YES;
    } else {
        return NO;
    }
}

@end
