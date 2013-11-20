//
//  ZSProgram.m
//  Zuse
//
//  Created by Michael Hogenson on 10/5/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSProgram.h"
#import "TCSprite.h"

@interface ZSProgram()

@property (nonatomic, strong) NSDictionary * rawJSON;

@end

@implementation ZSProgram

- (id)init {
    self = [super init];
    if (self) {
        _sprites = [[NSMutableArray alloc] init];
    }
    return self;
}

+(ZSProgram *)programForResource:(NSString *)name ofType:(NSString *)extension {
    
    // Read the resource into an NSDictionary representing the JSON.
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

    // Load the program into memory.
    ZSProgram *program = [[ZSProgram alloc] init];
    program.rawJSON = json;
    program.version = [json[@"version"] floatValue];
    program.interpreterVersion = [json[@"interpreter_version"] floatValue];
    
    // Load the sprites.
    for (NSDictionary *jsonObject in json[@"objects"]) {
        NSDictionary *variables = jsonObject[@"properties"];
        
        // Load the sprite frame.
        CGRect frame = CGRectZero;
        frame.origin.x = [variables[@"x"] floatValue];
        frame.origin.y = [variables[@"y"] floatValue];
        frame.size.width = [variables[@"width"] floatValue];
        frame.size.height = [variables[@"height"] floatValue];
        
        TCSprite *sprite = [[TCSprite alloc] init];
        sprite.identifier = jsonObject[@"id"];
        sprite.frame = frame;
        sprite.code = jsonObject[@"code"];
        sprite.traits = jsonObject[@"traits"];
        
        [program.sprites addObject:sprite];
    }
    
    return program;
}

-(void)saveToResource:(NSString *)name ofType:(NSString *)extension {
    
}

-(NSDictionary *)projectJSON {
    NSMutableDictionary *projectJSON = [NSMutableDictionary dictionary];
    [projectJSON setObject:_rawJSON[@"traits"] forKey:@"traits"];
    
    NSMutableArray *objects = [NSMutableArray array];
    for (TCSprite *sprite in _sprites) {
        NSMutableDictionary *object = [NSMutableDictionary dictionary];
        [object setObject:sprite.code forKey:@"code"];
        [object setObject:sprite.identifier forKey:@"id"];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        [properties setObject:@(sprite.frame.origin.x) forKey:@"x"];
        [properties setObject:@(sprite.frame.origin.y) forKey:@"y"];
        [properties setObject:@(sprite.frame.size.width) forKey:@"width"];
        [properties setObject:@(sprite.frame.size.height) forKey:@"height"];
        
        [object setObject:properties forKey:@"properties"];
        [object setObject:sprite.traits forKey:@"traits"];
        [objects addObject:object];
    }
    
    [projectJSON setObject:objects forKey:@"objects"];
    
    NSLog(@"%@", projectJSON);
    
    return projectJSON;
}

@end
