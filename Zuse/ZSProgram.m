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

-(id)initWithFile:(NSString *)name{
    self = [super init];
    if (self) {
        _sprites = [[NSMutableArray alloc] init];
        NSData *jsonData = nil;
        // NSString *path = [self completePathForFile:name];
        // NSLog(@"%@", path);
        // if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //     jsonData = [NSData dataWithContentsOfFile:path];
        // } else {
        // Look for the project in the bundle.
        NSString *modifiedName = [name componentsSeparatedByString:@"."][0];
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:modifiedName ofType:@"json"];
        jsonData = [NSData dataWithContentsOfFile:jsonPath];
        // }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        // Load the program into memory.
        _rawJSON = json;
        _version = [json[@"version"] floatValue];
        _interpreterVersion = [json[@"interpreter_version"] floatValue];
        
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
            
            NSDictionary *image = jsonObject[@"image"];
            sprite.imagePath = image[@"path"];
            
            [_sprites addObject:sprite];
        }
    }
    return self;
}

-(NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentsDirectory);
    return documentsDirectory;
}

-(NSString *)completePathForFile:(NSString *)name {
    return [NSString stringWithFormat:@"%@/%@", [self documentDirectory], name];
}

+(ZSProgram *)programWithFile:(NSString *)name {
    return [[ZSProgram alloc] initWithFile:name];
}

-(void)writeToFile:(NSString *)name {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self projectJSON] options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing: %@", error);
    } else {
        [jsonData writeToFile:[self completePathForFile:name] options:0 error:nil];
    }
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
        
        if (sprite.imagePath) {
            NSMutableDictionary *image = [NSMutableDictionary dictionary];
            [image setObject:sprite.imagePath forKey:@"path"];
            [object setObject:image forKey:@"image"];
        }
        
        [object setObject:properties forKey:@"properties"];
        [object setObject:sprite.traits forKey:@"traits"];
        [objects addObject:object];
    }
    
    [projectJSON setObject:objects forKey:@"objects"];
    
    return projectJSON;
}

@end
