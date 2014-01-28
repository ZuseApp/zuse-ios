//
//  ZSRendererScene.h
//  Zuse
//
//  Created by Sarah Hong on 10/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <SpriteKit-Components/SKComponents.h>
#import "ZSInterpreter.h"

@interface ZSRendererScene : SKComponentScene <SKPhysicsContactDelegate>

- (instancetype)initWithSize:(CGSize)size projectJSON:(NSDictionary *)projectJSON;

@property (strong, nonatomic, readonly) ZSInterpreter *interpreter;

@end
