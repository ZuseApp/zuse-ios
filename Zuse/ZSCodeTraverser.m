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
    // TODO: Create transform that adds in false branches to all if statements
    return @[codeItem[@"if"][@"true"], codeItem[@"if"][@"false"] ?: @[]];
}

+ (NSArray *)codeBlocksForOnEvent:(NSDictionary *)codeItem {
    return @[(codeItem[@"on_event"][@"code"] ?: @[])];
}

+ (NSArray *)codeBlocksForSuite:(NSDictionary *)codeItem {
    return @[codeItem[@"suite"] ?: @[]];
}

+ (NSArray *)codeBlocksForObject:(NSDictionary *)codeItem {
    return @[codeItem[@"object"][@"code"] ?: @[]];
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
        newCodeItem = codeItem;
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

+ (NSDictionary *)map:(NSDictionary *)codeItem block:(NSDictionary *(^)(NSDictionary *))replacementBlock {
    return [self reduce:@[codeItem] block:^NSArray *(NSArray *innerCodeItems, NSDictionary *innerCodeItem) {
        NSDictionary *replacement = replacementBlock(innerCodeItem);
        return [innerCodeItems arrayByAddingObject:replacement];
    }].firstObject ?: @[];
}

+ (NSDictionary *)filter:(NSDictionary *)codeItem block:(ZSCodeValidBlock)testBlock {
    return [self reduce:@[codeItem] block:^NSArray *(NSArray *innerCodeItems, NSDictionary *innerCodeItem) {
        if (testBlock(innerCodeItem)) {
            return [innerCodeItems arrayByAddingObject:innerCodeItem];
        } else {
            return innerCodeItems;
        }
    }].firstObject ?: @[];
}

+ (NSArray *)reduce:(NSArray *)codeItems block:(NSArray *(^)(NSArray *innerCodeItems, NSDictionary *innerCodeItem))reduceBlock {
    __block NSArray *result = @[];
    
    [codeItems each:^(NSDictionary *codeItem) {
        result = reduceBlock(result, codeItem);
    }];
    
    result = [result map:^(NSDictionary *transformedItem) {
        NSArray *codeBlocks = [self codeBlocksForCodeItem:transformedItem];
        
        codeBlocks =  [codeBlocks map:^id(NSArray *codeBlock) {
            return [self reduce:codeBlock block:reduceBlock];
        }];
        
        return [self codeItemBySettingCodeBlocks:codeBlocks
                                     forCodeItem:transformedItem];
    }];
    
    return result;
}

+ (NSDictionary *)map:(NSDictionary *)codeItem onKeys:(NSArray *)codeItemKeys block:(ZSCodeTransformBlock)transformBlock {
    NSSet *keySet = [NSSet setWithArray:codeItemKeys];
    return [self map:codeItem block:^NSDictionary *(NSDictionary *innerCodeItem) {
        NSString *key = innerCodeItem.allKeys.firstObject;
        if ([keySet containsObject:key]) {
            return transformBlock(innerCodeItem);
        } else {
            return innerCodeItem;
        }
    }];
}

@end
