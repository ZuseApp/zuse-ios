//
//  ZSScene.m
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSScene.h"

@interface ZSScene ()

@property (strong, nonatomic) NSArray *colors;

@end

@implementation ZSScene

-(NSArray *) colors {
    if (!_colors) {
        _colors = @[[SKColor redColor], [SKColor orangeColor], [SKColor yellowColor], [SKColor greenColor], [SKColor cyanColor], [SKColor blueColor], [SKColor purpleColor]];
    }
    
    return _colors;
}

-(SKColor *) randomColor {
    int index = arc4random() % [self colors].count;
    return [self colors][index];
}

-(void) addRandomSprite {
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"grayball"];
    sprite.position = CGPointMake(self.frame.size.width/4 + arc4random() % ((int)self.frame.size.width/2),
                                  self.frame.size.height/2 + arc4random() % ((int)self.frame.size.height/4));
    sprite.color = [self randomColor];
    sprite.colorBlendFactor = 1.0;
    sprite.xScale = 0.2;
    sprite.yScale = 0.2;
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width / 2];
    
    [self addChild:sprite];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.scaleMode = SKSceneScaleModeAspectFill;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self addRandomSprite];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
