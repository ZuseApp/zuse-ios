//
//  ZSCompiler.m
//  Zuse
//
//  Created by Parker Wightman on 11/16/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCompiler.h"
#import "BlocksKit.h"
#import "ZSCodeTraverser.h"
#import "ZSCodeNormalizer.h"
#import "ZSCodeTransforms.h"

@interface ZSCompiler ()

@property (strong, nonatomic) NSDictionary *projectJSON;

@end

@implementation ZSCompiler

+ (instancetype) compilerWithProjectJSON:(NSDictionary *)projectJSON {
    ZSCompiler *compiler = [[self alloc] init];
    
    if (self ) {
        compiler.projectJSON = projectJSON;
    }
    
    return compiler;
}

- (NSDictionary *)compiledJSON {
    NSArray *newObjects = self.projectJSON[@"objects"];
    
    NSMutableDictionary *traits = self.projectJSON[@"traits"];
    if (traits) {
        newObjects = [self objectsByInliningTraits:traits
                                           objects:newObjects];
    }
    
    newObjects = [self.class zuseIRObjectsFromDSLObjects:newObjects];
    
    NSDictionary *code = @{ @"suite": newObjects };

    code = [ZSCodeNormalizer normalizedCodeItem:code];
    code = [ZSCodeTraverser map:code onKeys:@[@"every"] block:ZSCodeTransformEveryBlock];
    
    return code;
}

- (NSArray *)objectsByInliningTraits:(NSDictionary *)traits objects:(NSArray *)objects {
    NSArray *newObjects = [self.projectJSON[@"objects"] map:^id(NSDictionary *object) {
        NSMutableDictionary *newObject = [object mutableCopy];
        if (!newObject[@"code"])
            newObject[@"code"] = [NSMutableArray array];
        else
            newObject[@"code"] = [newObject[@"code"] mutableCopy];
        
        NSDictionary *objectTraits = object[@"traits"];
        
        if (objectTraits && objectTraits.count > 0) {
            [objectTraits each:^(NSString *identifier, NSDictionary *traitOptions) {
                NSDictionary *globalTrait = traits[identifier];
                
                if (globalTrait) {
                    NSMutableDictionary *traitParams = [globalTrait[@"parameters"] mutableCopy];
                    [(NSDictionary *)traitOptions[@"parameters"] each:^(id key, id obj) {
                        traitParams[key] = obj;
                    }];
                    
                    NSMutableArray *paramsExpressions = [NSMutableArray array];
                    
                    [traitParams each:^(id key, id obj) {
                        [paramsExpressions addObject:@{ @"set": @[key, obj] }];
                    }];
                    
                    NSArray *newSuite = [paramsExpressions arrayByAddingObjectsFromArray:globalTrait[@"code"]];
                    
                    NSDictionary *newStatement = @{ @"suite": newSuite };
                    [newObject[@"code"] addObject:newStatement];
                } else {
                    NSLog(@"Trait not found: %@", identifier);
                }
            }];
        }
        
        [newObject removeObjectForKey:@"traits"];
        
        return newObject;
    }];
    
    return newObjects;
}

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
+ (NSArray *)zuseIRObjectsFromDSLObjects:(NSArray *)objects {
    NSArray *newObjects = [objects map:^id(NSDictionary *obj) {
        return @{
            @"object": @{
                @"id": obj[@"id"],
                @"properties": (obj[@"properties"] ?: @{}),
                @"code": (obj[@"code"] ?: @[])
            }
        };
    }];
    
    return newObjects;
}

@end