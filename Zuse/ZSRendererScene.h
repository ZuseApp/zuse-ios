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

@interface ZSRendererScene : SKComponentScene


- (instancetype)initWithSize:(CGSize)size interpreter:(ZSInterpreter *)interpreter;

@end
