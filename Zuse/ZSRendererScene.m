//
//  ZSRendererScene.m
//  Zuse
//
//  Created by Sarah Hong on 10/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSRendererScene.h"
#import "ZSSpriteTouchComponent.h"
#import <SpriteKit-Components/SKComponents.h>
#import <BlocksKit/BlocksKit.h>
#import <PhysicsDebugger/YMCPhysicsDebugger.h>
#import <PhysicsDebugger/YMCSKNode+PhysicsDebug.h>

@interface ZSRendererScene() <ZSInterpreterDelegate>

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSMutableDictionary *spriteNodes;

@property (strong, nonatomic) ZSInterpreter *interpreter;

@end


@implementation ZSRendererScene

-(id)initWithSize:(CGSize)size  interpreter:(ZSInterpreter *)interpreter {
    if (self = [super initWithSize:size]) {
        
    
        _interpreter = interpreter;
        _interpreter.delegate = self;
        
        NSDictionary *objects = [_interpreter objects];
        
        //init the debugger
        [YMCPhysicsDebugger init];
        
        //Set the physics edges to the frame
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
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
            
            //add the node as a physics body for physics debugging
            //sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
            
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
        
        //call debug render method
        [self drawPhysicsBodies];
        
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

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
}

@end
