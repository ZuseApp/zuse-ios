//
//  ZSCodeTraverser.h
//  Zuse
//
//  Created by Parker Wightman on 3/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSCodeTransforms.h"

@interface ZSCodeTraverser : NSObject

/**
 *  Useful for performing tree transforms on code. `replacementBlock` is called for every 
 *  statement found recursively in entire code structure, traversing all code paths.
 *
 *  @param code             NSDictionary object representing a single statement in the Zuse IR
 *  @param replacementBlock Block called for every statement/expression found in `codeItem`.
 *                          Returned NSDictionary replaces passed NSDictionary in final structure.
 *
 *  @return A new NSDictionary with any statements/expression transformed by replacementBlock
 */
+ (NSDictionary *)codeItemByTraversingCodeItem:(NSDictionary *)codeItem
              replacingItemsWithBlock:(ZSCodeTransformBlock)replacementBlock;

/**
 *  Transforms any statements identified in the Zuse IR by `codeItemKey` using
 *  `transformBlock`. All other code items will remain unchanged.
 *
 *  @param codeItem       Code item from Zuse domain language
 *  @param codeItemKey    Key representing code items to match
 *  @param transformBlock A block that performs some tranformation on statements identified
                          by `codeItemKey`.
 *
 *  @return New code item, potentially transformed.
 */
+ (NSDictionary *)codeItemByTransformingCodeItem:(NSDictionary *)codeItem
                                         withKey:(NSString *)codeItemKey
                                      usingBlock:(ZSCodeTransformBlock)transformBlock;

/**
 *  Find all code blocks associated with `object` key in Zuse domain language.
 *
 *  @param codeItem `object` code item from Zuse domain language
 *
 *  @return Array of code blocks
 */
+ (NSArray *)codeBlocksForObject:(NSDictionary *)codeItem;

/**
 *  Find all code blocks associated with `on_event` key in Zuse domain language.
 *
 *  @param codeItem `on_event` code item from Zuse domain language
 *
 *  @return Array of code blocks
 */
+ (NSArray *)codeBlocksForOnEvent:(NSDictionary *)codeItem;

/**
 *  Find all code blocks associated with `if` key in Zuse domain language.
 *
 *  @param codeItem `if` code item from Zuse domain language
 *
 *  @return Array of code blocks
 */
+ (NSArray *)codeBlocksForIf:(NSDictionary *)codeItem;

/**
 *  Find all code blocks associated with `suite` key in Zuse domain language.
 *
 *  @param codeItem `suite` code item from Zuse domain language
 *
 *  @return Array of code blocks
 */
+ (NSArray *)codeBlocksForSuite:(NSDictionary *)codeItem;

// These are the inverse of the above 4 methods, setting the code
// blocks instead of extracting them
+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                   forOnEvent:(NSDictionary *)codeItem;

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                      forSuite:(NSDictionary *)codeItem;

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                        forIf:(NSDictionary *)codeItem;

+ (NSDictionary *)codeItemBySettingCodeBlocks:(NSArray *)codeBlocks
                                    forObject:(NSDictionary *)codeItem;

@end
