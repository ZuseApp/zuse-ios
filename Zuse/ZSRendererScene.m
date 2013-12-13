//
//  ZSRendererScene.m
//  Zuse
//
//  Created by Sarah Hong on 10/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <SpriteKit-Components/SKComponents.h>
#import <BlocksKit/BlocksKit.h>
#import <PhysicsDebugger/YMCPhysicsDebugger.h>
#import <PhysicsDebugger/YMCSKNode+PhysicsDebug.h>
@import GLKit;

#import "ZSRendererScene.h"
#import "ZSSpriteTouchComponent.h"
#import "ZSCompiler.h"

@interface ZSRendererScene() <ZSInterpreterDelegate>

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSMutableDictionary *spriteNodes;
@property (nonatomic) NSMutableDictionary *movingSprites;

@property (strong, nonatomic) ZSInterpreter *interpreter;

@end

NSString * const kZSSpriteName = @"sprite";
CGFloat const kZSSpriteSpeed = 200;

@implementation ZSRendererScene

-(id)initWithSize:(CGSize)size projectJSON:(NSDictionary *)projectJSON {
    if (self = [super initWithSize:size]) {
        _movingSprites = [NSMutableDictionary dictionary];
    
        ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:projectJSON];
        _interpreter = [compiler interpreter];
        
        [self loadMethodsIntoInterpreter];
        
        _interpreter.delegate = self;
        
        //init the debugger
        // [YMCPhysicsDebugger init];
        
        //Set the physics edges to the frame
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        // TODO: render objects on screen...
        _spriteNodes = [[NSMutableDictionary alloc] init];
        [projectJSON[@"objects"] each:^(NSDictionary *object) {
            
            NSDictionary *properties = object[@"properties"];
            
            SKComponentNode *node = [SKComponentNode node];
            node.name = kZSSpriteName;
            ZSSpriteTouchComponent *component = [ZSSpriteTouchComponent new];

            component.touchesMoved = ^(UITouch *touch) {
                CGPoint point = [touch locationInNode:self];
                [_interpreter triggerEvent:@"touch_moved"
                    onObjectWithIdentifier:object[@"id"]
                                parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            
            component.touchesBegan = ^(UITouch *touch) {
                CGPoint point = [touch locationInNode:self];
                [_interpreter triggerEvent:@"touch_began"
                    onObjectWithIdentifier:object[@"id"]
                                parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            
            [node addComponent:component];
            
            //set up the sprite size and position on screen
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
            
            node.position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            
            sprite.size = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
            
            
            //add the node as a physics body for physics debugging
            if ([object[@"physics_body"] isEqualToString:@"circle"]) {
                node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(sprite.size.width / 2)];
            } else {
                node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
            }
            node.physicsBody.dynamic = NO;
            node.physicsBody.mass = 0.02;
            node.physicsBody.affectedByGravity = NO;
            
            //add the sprite to the scene
            [node addChild:sprite];
            
            [self addChild:node];
            
            //call debug render method
            // [self drawPhysicsBodies];
            
            // ...
            [_spriteNodes setObject:node forKey:object[@"id"]];
        }];
        
        // getting size of screen
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // setting background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
       
        
    }
    return self;
}

- (void)moveSpriteWithIdentifier:(NSString *)identifier
                       direction:(CGFloat)direction
                           speed:(CGFloat)speed {
    [_movingSprites setObject:@(speed) forKey:identifier];
    SKNode *node = _spriteNodes[identifier];
    node.physicsBody.dynamic = YES;
    node.physicsBody.velocity = CGVectorMake(kZSSpriteSpeed, kZSSpriteSpeed);
}

- (void)didSimulatePhysics {
    
    [self enumerateChildNodesWithName:kZSSpriteName
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               GLKVector2 velocity = GLKVector2Make(node.physicsBody.velocity.dx, node.physicsBody.velocity.dy);
                               GLKVector2 direction = GLKVector2Normalize(velocity);
                               GLKVector2 newVelocity = GLKVector2MultiplyScalar(direction, kZSSpriteSpeed);
                               node.physicsBody.velocity = CGVectorMake(newVelocity.x, newVelocity.y);
//                               node.physicsBody.angularVelocity = 0.0;
                           }];
    
}

- (void)loadMethodsIntoInterpreter {
    [_interpreter loadMethod:@{
        @"method": @"move",
        @"block": ^id(NSString *identifier, NSArray *args) {
            CGFloat direction = [args[0] floatValue];
            CGFloat speed = [args[1] floatValue];
            [self moveSpriteWithIdentifier:identifier
                                 direction:direction
                                     speed:speed];
            return nil;
        }
    }];
}

- (void)interpreter:(ZSInterpreter *)interpreter
objectWithIdentifier:(NSString *)identifier
didUpdateProperties:(NSDictionary *)properties {
    SKComponentNode *sprite = _spriteNodes[identifier];
    if (properties[@"x"])
        sprite.position = CGPointMake([properties[@"x"] floatValue], sprite.position.y);
    if (properties[@"y"])
        sprite.position = CGPointMake(sprite.position.x, [properties[@"y"] floatValue]);
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
