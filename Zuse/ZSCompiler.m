//
//  ZSCompiler.m
//  Zuse
//
//  Created by Parker Wightman on 11/16/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSCompiler.h"
#import "BlocksKit.h"

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
    NSMutableDictionary *traits = _projectJSON[@"traits"];
    
    NSArray *newObjects = _projectJSON[@"objects"];
    
    if (traits) {
        newObjects = [self objectsByInliningTraits:_projectJSON[@"traits"]
                                           objects:_projectJSON[@"objects"]];
    }
    
    newObjects = [self transformedObjectsForObjects:newObjects];
    
    return @{ @"code": newObjects };
}

- (NSArray *)objectsByInliningTraits:(NSDictionary *)traits objects:(NSArray *)objects {
    NSArray *newObjects = [_projectJSON[@"objects"] map:^id(NSDictionary *object) {
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
                    
                    NSDictionary *newStatement = @{ @"scope": newSuite };
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

- (NSArray *)transformedObjectsForObjects:(NSArray *)objects {
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
