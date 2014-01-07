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
    
    if (!traits) return _projectJSON[@"objects"];
    
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
    
    NSLog(@"%@", newObjects);
    
    return @{ @"objects": newObjects };
}

- (ZSInterpreter *)interpreter {
    ZSInterpreter *interpreter = [ZSInterpreter interpreter];
    [[self compiledJSON][@"objects"] each:^(NSDictionary *object) {
        [interpreter loadObject:object];
    }];
    
    return interpreter;
}

@end
