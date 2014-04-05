//
//  ZSCompiler.h
//  Zuse
//
//  Created by Parker Wightman on 11/16/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSCompiler : NSObject

/**
 *  Returns a new compiler for the given project JSON.
 *
 *  @param projectJSON The project file structure
 *
 *  @return ZSCompiler object
 */
+ (instancetype) compilerWithProjectJSON:(NSDictionary *)projectJSON;

/**
 *  Returns a compiled form of the project JSON that can be passed directly
 *  to a ZSInterpreter object (or anything implementing the Zuse IR)
 *
 *  @return NSDictionary representing the compiled JSON
 */
- (NSDictionary *)compiledJSON;

/**
 *
 * Turns a Zuse iOS app-specific object, that might have a physics body/etc., into just the things
 * the interpreter needs and turns them into 'object' statements that the interpreter natively
 * understands.
 *
 *  @param objects Project JSON-specific objects
 *
 *  @return Array of `object` statements from the Zuse IR
 */
+ (NSArray *)zuseIRObjectsFromDSLObjects:(NSArray *)objects;

@end
