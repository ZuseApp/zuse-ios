//
//  ZSCodeTransforms.h
//  Zuse
//
//  Created by Parker Wightman on 3/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary *(^ZSCodeTransformBlock)(NSDictionary *codeItem);

/**
 * Transforms Zuse DSL 'every' statement into Zuse IR
 * primitives. Makes the following conversion:
 *
 * {
 *   "every": { "seconds": 1, "code": [ ] }
 * }
 *
 * Turns into:
 *
 * {
 *   "suite": [
 *     { on_event: { "name": "abcd", "parameters": [], "code": [] } },
 *     { "call": { "method": "every_seconds", "parameters": [1, "abcd"] } }
 *   ]
 * }
 */
extern ZSCodeTransformBlock ZSCodeTransformEveryBlock;

/**
 * Transforms Zuse DSL 'after' statement into Zuse IR
 * primitives. Makes the following conversion:
 *
 * {
 *   "after": { "seconds": 1, "code": [ ] }
 * }
 *
 * Turns into:
 *
 * {
 *   "suite": [
 *     { on_event: { "name": "abcd", "parameters": [], "code": [] } },
 *     { "call": { "method": "after_seconds", "parameters": [1, "abcd"] } }
 *   ]
 * }
 */
extern ZSCodeTransformBlock ZSCodeTransformAfterBlock;

/**
 * Transforms Zuse DSL 'in' statement into Zuse IR
 * primitives. Makes the following conversion:
 *
 * {
 *   "in": { "seconds": 1, "code": [ ] }
 * }
 *
 * Turns into:
 *
 * {
 *   "suite": [
 *     { on_event: { "name": "abcd", "parameters": [], "code": [] } },
 *     { "call": { "method": "in_seconds", "parameters": [1, "abcd"] } }
 *   ]
 * }
 */
extern ZSCodeTransformBlock ZSCodeTransformInBlock;