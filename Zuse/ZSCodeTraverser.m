//
//  ZSCodeTraverser.m
//  Zuse
//
//  Created by Parker Wightman on 3/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSCodeTraverser.h"
#import "BlocksKit.h"

@implementation ZSCodeTraverser

+ (NSArray *)codeBlocksForIf:(NSDictionary *)codeItem {
    return @[codeItem[@"if"][@"true"], codeItem[@"if"][@"false"]];
}

+ (NSArray *)codeBlocksForOnEvent:(NSDictionary *)codeItem {
    return @[codeItem[@"on_event"][@"code"]];
}

+ (NSArray *)codeBlocksForSuite:(NSDictionary *)codeItem {
    return @[codeItem[@"suite"]];
}

+ (NSArray *)codeBlocksForObject:(NSDictionary *)codeItem {
    return @[codeItem[@"object"][@"code"]];
}

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                   forOnEvent:(NSDictionary *)codeItem {
    NSMutableDictionary *newItem = [codeItem deepMutableCopy];
    newItem[@"on_event"][@"code"] = codeBlocks[0];
    return newItem;
}

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                      forSuite:(NSDictionary *)codeItem {
    NSMutableDictionary *newItem = [codeItem deepMutableCopy];
    newItem[@"suite"] = codeBlocks[0];
    return newItem;
}

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                        forIf:(NSDictionary *)codeItem {
    NSMutableDictionary *newItem = [codeItem deepMutableCopy];
    newItem[@"if"][@"true"]  = codeBlocks[0];
    newItem[@"if"][@"false"] = codeBlocks[1];
    return newItem;
}

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                    forObject:(NSDictionary *)codeItem {
    NSMutableDictionary *newItem = [codeItem deepMutableCopy];
    newItem[@"object"][@"code"]  = codeBlocks[0];
    return newItem;
}

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                  forCodeItem:(NSDictionary *)codeItem {
    NSString     *key         = codeItem.allKeys.firstObject;
    NSDictionary *newCodeItem = nil;

    if ([key isEqualToString:@"if"]) {
        newCodeItem = [self codeItemBySettingCodeBlocks:codeBlocks forIf:codeItem];
    } else if ([key isEqualToString:@"on_event"]) {
        newCodeItem = [self codeItemBySettingCodeBlocks:codeBlocks forOnEvent:codeItem];
    } else if ([key isEqualToString:@"suite"]) {
        newCodeItem = [self codeItemBySettingCodeBlocks:codeBlocks forSuite:codeItem];
    } else if ([key isEqualToString:@"object"]) {
        newCodeItem = [self codeItemBySettingCodeBlocks:codeBlocks forObject:codeItem];
    } else {
        return newCodeItem = codeItem;
    }
    return newCodeItem;
}

+ (NSArray *)codeBlocksForCodeItem:(NSDictionary *)codeItem {
    NSString *key = codeItem.allKeys.firstObject;
    if ([key isEqualToString:@"if"]) {
        return [self codeBlocksForIf:codeItem];
    } else if ([key isEqualToString:@"suite"]) {
        return [self codeBlocksForSuite:codeItem];
    } else if ([key isEqualToString:@"on_event"]) {
        return [self codeBlocksForOnEvent:codeItem];
    } else if ([key isEqualToString:@"object"]) {
        return [self codeBlocksForObject:codeItem];
    } else {
        return @[];
    }
}

+ (NSDictionary *)codeItemByTraversingCodeItem:(NSDictionary *)codeItem
                       replacingItemsWithBlock:(NSDictionary *(^)(NSDictionary *))replacementBlock {
    NSDictionary *transformedItem = replacementBlock(codeItem);
    
    NSArray *codeBlocks = [self codeBlocksForCodeItem:transformedItem];
    
    codeBlocks = [codeBlocks map:^id(NSArray *codeBlock) {
        return [codeBlock map:^id(NSDictionary *innerCodeItem) {
            return [self codeItemByTraversingCodeItem:innerCodeItem replacingItemsWithBlock:replacementBlock];
        }];
    }];
    
    return [self codeItemBySettingCodeBlocks:codeBlocks
                                 forCodeItem:transformedItem];
}

+ (NSDictionary *)codeItemByTransformingCodeItem:(NSDictionary *)codeItem
                                         withKey:(NSString *)codeItemKey
                                      usingBlock:(NSDictionary *(^)(NSDictionary *))transformBlock {
    return [self codeItemByTraversingCodeItem:codeItem
                      replacingItemsWithBlock:^NSDictionary *(NSDictionary *innerCodeItem) {
                          NSString *key = innerCodeItem.allKeys.firstObject;
                          if ([key isEqualToString:codeItemKey]) {
                              return transformBlock(innerCodeItem);
                          } else {
                              return innerCodeItem;
                          }
                      }];
}

@end
