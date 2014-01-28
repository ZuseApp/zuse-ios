//
//  ZSSpriteLibrary.m
//  Zuse
//
//  Created by Michael Hogenson on 12/6/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSpriteLibrary.h"

@implementation ZSSpriteLibrary

+(NSMutableArray *) spriteLibrary {
    NSMutableArray *sprites = [NSMutableArray array];
    
    // Load sprites from the manifest file.
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [bundleRoot stringByAppendingPathComponent:@"sprite_manifest.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray *manifestJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    for (NSDictionary *manifest_sprite in manifestJSON) {
        NSDictionary *sprite = @{
                                 @"physics_body": manifest_sprite[@"physics_body"],
                                 @"traits": @{},
                                 @"properties": @{
                                         @"width": manifest_sprite[@"preferred_size"][@"width"],
                                         @"height": manifest_sprite[@"preferred_size"][@"height"]
                                         },
                                 @"image": @{
                                         @"path": manifest_sprite[@"path"],
                                         },
                                 @"code": @{},
                                 @"type": @"image"
                                 };
        [sprites addObject:sprite];
    }
    
    NSDictionary *textSprite = @{
                                 @"physics_body": @"rectangle",
                                 @"traits": @{},
                                 @"properties": @{
                                         @"width": @(200),
                                         @"height": @(20)
                                         },
                                 @"code": @{},
                                 @"type": @"text"
                                 };
    [sprites addObject:textSprite];
    
    return sprites;
}

@end
