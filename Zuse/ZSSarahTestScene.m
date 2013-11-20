//
//  ZSSarahTestScene.m
//  Zuse
//
//  Created by Sarah Hong on 10/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSarahTestScene.h"
#import "ZSSpriteTouchComponent.h"
#import <SpriteKit-Components/SKComponents.h>
#import <BlocksKit/BlocksKit.h>

@interface ZSSarahTestScene() <ZSInterpreterDelegate>

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSMutableDictionary *spriteNodes;

@property (strong, nonatomic) ZSInterpreter *interpreter;

@end


@implementation ZSSarahTestScene

-(id)initWithSize:(CGSize)size  interpreter:(ZSInterpreter *)interpreter {
    if (self = [super initWithSize:size]) {
        
    
        _interpreter = interpreter;
        _interpreter.delegate = self;
        
        NSDictionary *objects = [_interpreter objects];
        
        // TODO: render objects on screen...
        _spriteNodes = [[NSMutableDictionary alloc] init];
        [objects each:^(id key, NSDictionary *properties) {
            
            SKComponentNode *node = [SKComponentNode node];
            ZSSpriteTouchComponent *component = [ZSSpriteTouchComponent new];

            component.touchesMoved = ^(UITouch *touch) {
                CGPoint point = [touch locationInNode:self];
//                NSLog(@"touch moved");
//                NSLog(@"%@", touch);
                [_interpreter triggerEvent:@"touch_moved"
                    onObjectWithIdentifier:key
                                parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            [node addComponent:component];
            
            //set up the sprite size and position on screen
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
            
            node.position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            
            sprite.size = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
            
            
            //add the sprite to the scene
            [node addChild:sprite];
            
            [self addChild:node];
            
            // ...
            [_spriteNodes setObject:node forKey:key];
        }];
        
        
        // getting size of screen
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // setting background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // tutorial code; adding sprite to scene
//        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
//        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
//        [self addChild:self.player];
        
    }
    return self;
}

- (void)interpreter:(ZSInterpreter *)interpreter
objectWithIdentifier:(NSString *)identifier
didUpdateProperties:(NSDictionary *)properties {
     // TODO: Update properties of onscreen objects based on changes.
     // TODO: Create some node (Sprite object from interpreter) and add NodeComponent (move event i.e. touchMoved). touchMoved implementation has no concept of how sprite will be interacting with Zuse code, so must be generic and simply grab out the coordinate info for that sprite. This info must be transferred into the scene, then the scene will pass this info to the interpreter (ex; event->touchMoved, sprite->paddle1, parameters->touchX, touchY).
    SKComponentNode *sprite = _spriteNodes[identifier];
    if (properties[@"x"])
        sprite.position = CGPointMake([properties[@"x"] floatValue], sprite.position.y);
    if (properties[@"y"])
        sprite.position = CGPointMake(sprite.position.x, [properties[@"y"] floatValue]);
    
    NSLog(@"%@", properties);
}

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

@end
