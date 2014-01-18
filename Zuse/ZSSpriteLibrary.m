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
    // TODO: Create from json library but for now return pong sprites.
    NSMutableArray *sprites = [NSMutableArray array];
    
    NSMutableDictionary *paddle = [NSMutableDictionary dictionary];
    paddle[@"physics_body"] = @"rectangle";
    NSMutableDictionary *image = [NSMutableDictionary dictionary];
    image[@"path"] = @"paddle.png";
    paddle[@"image"] = image;
    paddle[@"traits"] = [NSMutableDictionary dictionary];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[@"width"] = @(129);
    properties[@"height"] = @(28);
    paddle[@"properties"] = properties;
    paddle[@"code"] = [NSMutableArray array];
    
    NSMutableDictionary *ball = [NSMutableDictionary dictionary];
    ball[@"physics_body"] = @"circle";
    NSMutableDictionary *image2 = [NSMutableDictionary dictionary];
    image2[@"path"] = @"grayball.png";
    ball[@"image"] = image2;
    ball[@"traits"] = [NSMutableDictionary dictionary];
    NSMutableDictionary *properties2 = [NSMutableDictionary dictionary];
    properties2[@"width"] = @(30);
    properties2[@"height"] = @(30);
    ball[@"properties"] = properties2;
    ball[@"code"] = [NSMutableArray array];
    
    NSMutableDictionary *yoda = [NSMutableDictionary dictionary];
    yoda[@"physics_body"] = @"rectangle";
    NSMutableDictionary *image3 = [NSMutableDictionary dictionary];
    image3[@"path"] = @"yoda.jpeg";
    yoda[@"image"] = image3;
    yoda[@"traits"] = [NSMutableDictionary dictionary];
    NSMutableDictionary *properties3 = [NSMutableDictionary dictionary];
    properties3[@"width"] = @(259);
    properties3[@"height"] = @(194);
    yoda[@"properties"] = properties3;
    yoda[@"code"] = [NSMutableArray array];
    
    NSMutableDictionary *redBrick = [NSMutableDictionary dictionary];
    redBrick[@"physics_body"] = @"rectangle";
    NSMutableDictionary *image4 = [NSMutableDictionary dictionary];
    image4[@"path"] = @"red_brick.png";
    redBrick[@"image"] = image4;
    redBrick[@"traits"] = [NSMutableDictionary dictionary];
    NSMutableDictionary *properties4 = [NSMutableDictionary dictionary];
    properties4[@"width"] = @(64);
    properties4[@"height"] = @(32);
    redBrick[@"properties"] = properties4;
    redBrick[@"code"] = [NSMutableArray array];
    
    [sprites addObject:paddle];
    [sprites addObject:ball];
    [sprites addObject:yoda];
    [sprites addObject:redBrick];
    
    return sprites;
}

@end
