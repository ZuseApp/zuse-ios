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
@property (assign, nonatomic) ZSCompilerOptions compilerOptions;

@end

@implementation ZSCompiler

+ (instancetype) compilerWithProjectJSON:(NSDictionary *)projectJSON {
    ZSCompiler *compiler = [[self alloc] init];
    
    if (self ) {
        compiler.projectJSON = projectJSON;
    }
    
    return compiler;
}

+ (instancetype) compilerWithProjectJSON:(NSDictionary *)projectJSON options:(ZSCompilerOptions)options {
    ZSCompiler *compiler = [self compilerWithProjectJSON:projectJSON];
    compiler.compilerOptions = options;

    return compiler;
}

- (NSDictionary *)compiledComponents {
    NSArray *projectGenerators = (self.projectJSON[@"generators"] ?: @[]);
    NSDictionary *components = @{
        @"objects": self.projectJSON[@"objects"],
        @"generators": projectGenerators
    };

    components = [components map:^id(id key, NSArray *newObjects) {
        NSMutableDictionary *traits = self.projectJSON[@"traits"];

        if (traits) {
            newObjects = [self objectsByInliningTraits:traits
                                               objects:newObjects];
        }
        
        newObjects = [self.class zuseIRObjectsFromDSLObjects:newObjects
                                     shouldEmbedInStartEvent:self.compilerOptions & ZSCompilerOptionWrapInStartEvent];
        
        NSDictionary *code = @{ @"suite": newObjects };

        code = [ZSCodeNormalizer normalizedCodeItem:code];
        code = [ZSCodeTraverser map:code onKeys:@[@"every"] block:ZSCodeTransformEveryBlock];

        return code[@"suite"];
    }];

    NSArray *generatorsKeys = [projectGenerators map:^id(NSDictionary *generator) {
        return generator[@"name"];
    }];

    NSMutableDictionary *generators = [NSMutableDictionary dictionary];

    [components[@"generators"] enumerateObjectsUsingBlock:^(NSDictionary *generator, NSUInteger idx, BOOL *stop) {
        NSString *key = generatorsKeys[idx];
        generators[key] = generator;
    }];

    return @{
        @"objects": @{ @"suite": components[@"objects"] },
        @"generators": generators
    };
}

- (NSArray *)objectsByInliningTraits:(NSDictionary *)traits objects:(NSArray *)objects {
    NSArray *newObjects = [objects map:^id(NSDictionary *object) {
        NSMutableDictionary *newObject = [object deepMutableCopy];
        if (!newObject[@"code"]) {
            newObject[@"code"] = [NSMutableArray array];
        }

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
+ (NSArray *)zuseIRObjectsFromDSLObjects:(NSArray *)objects
                 shouldEmbedInStartEvent:(BOOL)shouldEmbed {

    NSArray *newObjects = [objects map:^id(NSDictionary *obj) {
        NSArray *code = (obj[@"code"] ?: @[]);

        if (shouldEmbed) {
            code = @[
                @{
                    @"on_event": @{
                        @"name": @"start",
                        @"code": (obj[@"code"] ?: @[])
                    }
                }
            ];
        }

        return @{
            @"object": @{
                @"id": obj[@"id"],
                @"properties": (obj[@"properties"] ?: @{}),
                @"code": code
            }
        };
    }];
    
    return newObjects;
}

@end