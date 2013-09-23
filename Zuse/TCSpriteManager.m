//
//  TCSpriteManager.m
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "TCSpriteManager.h"
#import "TCSprite.h"

@interface TCSpriteManager ()

- (void) prepareSprites;

@end

@implementation TCSpriteManager

+ (id)sharedManager {
    static TCSpriteManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        [self prepareSprites];
    }
    return self;
}

- (void)prepareSprites {
    _sprites = [NSMutableArray array];
    [_sprites addObject:[[TCSprite alloc] initWithImage:[UIImage imageNamed:@"dog.jpeg"]]];
    [_sprites addObject:[[TCSprite alloc] initWithImage:[UIImage imageNamed:@"monkey.jpeg"]]];
    [_sprites addObject:[[TCSprite alloc] initWithImage:[UIImage imageNamed:@"yoda.jpeg"]]];
    [_sprites addObject:[[TCSprite alloc] initWithImage:[UIImage imageNamed:@"sonic.jpeg"]]];
    [_sprites addObject:[[TCSprite alloc] initWithImage:[UIImage imageNamed:@"basketball.jpeg"]]];
}

@end
