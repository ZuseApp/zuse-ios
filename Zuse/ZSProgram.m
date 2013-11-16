//
//  ZSProgram.m
//  Zuse
//
//  Created by Michael Hogenson on 10/5/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSProgram.h"
#import "TCSprite.h"

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
        sprite.frame = frame;
        sprite.code = jsonObject[@"code"];
        
        [program.sprites addObject:sprite];
    }
    
    return program;
}

@end
