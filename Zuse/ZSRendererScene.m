//
//  ZSRendererScene.m
//  Zuse
//
//  Created by Sarah Hong on 10/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <SpriteKit-Components/SKComponents.h>
#import "BlocksKit.h"
@import GLKit;

#import "ZSRendererScene.h"
#import "ZSSpriteTouchComponent.h"
#import "ZSCompiler.h"

@interface ZSRendererScene() <ZSInterpreterDelegate>

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSMutableDictionary *spriteNodes;

@property (strong, nonatomic) ZSInterpreter *interpreter;

@end

NSString * const kZSSpriteName = @"sprite";
NSString * const kZSJointName = @"joint";
CGFloat const kZSSpriteSpeed = 200;

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
	GFPhysicsCategoryWorld  = 1 << 0,  // 0001 = 1
	GFPhysicsCategoryJoint  = 1 << 1,  // 0010 = 2
	GFPhysicsCategoryPaddle = 1 << 2,  // 0100 = 4
    GFPhysicsCategoryBall   = 1 << 3,
};

@implementation ZSRendererScene

-(id)initWithSize:(CGSize)size projectJSON:(NSDictionary *)projectJSON {
    if (self = [super initWithSize:size]) {
        ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:projectJSON];
        
        _interpreter = [ZSInterpreter interpreter];
        
        [self loadMethodsIntoInterpreter:_interpreter];
        
        [_interpreter runJSON:compiler.compiledJSON];
        
        _interpreter.delegate = self;
        
        //Set the physics edges to the frame
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = GFPhysicsCategoryWorld;
        
        
        // TODO: render objects on screen...
        _spriteNodes = [[NSMutableDictionary alloc] init];
        [projectJSON[@"objects"] each:^(NSDictionary *object) {
            
            NSDictionary *properties = object[@"properties"];
            
            CGPoint position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            CGSize size = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
        
            if ([object[@"type"] isEqualToString:@"text"]) {
                SKLabelNode *node = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                node.name = @"Text";
                node.text = properties[@"text"];
                node.fontColor = [SKColor blackColor];
                node.fontSize = 30;
                node.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                node.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                node.position = position;
                [self addChild:node];
                
                return;
            }
            
            SKComponentNode *node = [SKComponentNode node];
            node.name = kZSSpriteName;
            
            //set up the sprite size and position on screen
            
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
            sprite.alpha = 0.1;
            
            node.position = position;
            
            sprite.size = size;
            
            //add sprite to the node
            [node addChild:sprite];
            
            //add the node as a physics body for physics debugging
            SKComponentNode *jointNode = [SKComponentNode new];
            jointNode.position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            jointNode.name = kZSJointName;
            jointNode.alpha =1.0;
            // make a transparent sprite for the joint with the same dimensions as the node's sprite
            // SKSpriteNode *jointSprite = [SKSpriteNode new];
            SKSpriteNode *jointSprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
            jointSprite.size = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
            [jointNode addChild:jointSprite];
            
            if ([object[@"physics_body"] isEqualToString:@"circle"]) {
                node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(sprite.size.width / 2)];
                node.physicsBody.categoryBitMask = GFPhysicsCategoryBall;
                jointNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(sprite.size.width / 2)];
                node.physicsBody.collisionBitMask = GFPhysicsCategoryPaddle | GFPhysicsCategoryWorld;

            } else {
                node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
                jointNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
                node.physicsBody.categoryBitMask = GFPhysicsCategoryPaddle;
                node.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
                node.physicsBody.contactTestBitMask = GFPhysicsCategoryJoint;
            }
            
            jointNode.physicsBody.categoryBitMask = GFPhysicsCategoryJoint;
            
            SKPhysicsJointFixed *physicsJointFixed = [SKPhysicsJointFixed jointWithBodyA:node.physicsBody bodyB:jointNode.physicsBody anchor:node.position];
            
            ZSSpriteTouchComponent *touchComponent = [ZSSpriteTouchComponent new];
            
            touchComponent.touchesMoved = ^(UITouch *touch) {
                CGPoint point = [touch locationInNode:self];
              
                NSLog(@"move node position %g, %g", node.position.x, node.position.y);
                NSLog(@"move joint position %g, %g", jointNode.position.x, jointNode.position.y);
                
                    [_interpreter triggerEvent:@"touch_moved"
                        onObjectWithIdentifier:object[@"id"]
                                    parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
                
            };
            
            touchComponent.touchesBegan = ^(UITouch *touch) {
                CGPoint point = [touch locationInNode:self];
                
                NSLog(@"began node position %g, %g", node.position.x, node.position.y);
                NSLog(@"began joint position %g, %g", jointNode.position.x, jointNode.position.y);
                
                jointNode.position = node.position;
                [_interpreter triggerEvent:@"touch_began"
                    onObjectWithIdentifier:object[@"id"]
                                parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            
            touchComponent.touchesEnded = ^(UITouch *touch) {
                CGPoint point = node.position;
                
                jointNode.position = node.position;
                
//                [_interpreter triggerEvent:@"touch_ended"
//                    onObjectWithIdentifier:object[@"id"]
//                                parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            
            [jointNode addComponent:touchComponent];
            
            //TODO: see if there are issues with fixed joint physics body in case there are sync issues on movement.
            node.physicsBody.dynamic = YES;
            node.physicsBody.mass = 0.02;
            node.physicsBody.affectedByGravity = NO;
            
            jointNode.physicsBody.dynamic = NO;
//            jointNode.physicsBody.dynamic = YES;
            jointNode.physicsBody.mass = 0.02;
            jointNode.physicsBody.affectedByGravity = NO;
            //add both nodes to scene
            [self addChild:node];
            [self addChild:jointNode];
            [self.physicsWorld addJoint:physicsJointFixed];
            
            [_spriteNodes setObject:jointNode forKey:object[@"id"]];
            
        }];
        
        // setting background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    return self;
}


- (void)moveSpriteWithIdentifier:(NSString *)identifier
                       direction:(CGFloat)direction
                           speed:(CGFloat)speed {
    SKComponentNode *node = _spriteNodes[identifier];
    ZSSpriteTouchComponent *component = [node getComponent:[ZSSpriteTouchComponent class]];
    node.physicsBody.dynamic = YES;
    component.speed = speed;
    node.physicsBody.velocity = CGVectorMake(speed, speed);
}

- (void)didSimulatePhysics {
    
    [self enumerateChildNodesWithName:kZSJointName
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               NSLog(@"running");
                               SKComponentNode *componentNode = (SKComponentNode *)node;
                               ZSSpriteTouchComponent *touchNode = [componentNode getComponent:[ZSSpriteTouchComponent class]];
                               GLKVector2 velocity = GLKVector2Make(node.physicsBody.velocity.dx, node.physicsBody.velocity.dy);
                               GLKVector2 direction = GLKVector2Normalize(velocity);
                               GLKVector2 newVelocity = GLKVector2MultiplyScalar(direction, touchNode.speed);
                               node.physicsBody.velocity = CGVectorMake(newVelocity.x, newVelocity.y);
                               node.physicsBody.angularVelocity = 0.0;
                           }];
    
}

- (void)loadMethodsIntoInterpreter:(ZSInterpreter *)interpreter {
    [interpreter loadMethod:@{
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
    
    [interpreter loadMethod:@{
        @"method": @"remove",
        @"block": ^id(NSString *identifier, NSArray *args) {
            [self removeSpriteWithIdentifier:identifier];
            return nil;
        }
    }];
}

- (void)removeSpriteWithIdentifier:(NSString *)identifier {
    SKSpriteNode *node = _spriteNodes[identifier];
    [node removeFromParent];
    [_spriteNodes removeObjectForKey:identifier];
    [_interpreter removeObjectWithIdentifier:identifier];
}

- (void)interpreter:(ZSInterpreter *)interpreter
objectWithIdentifier:(NSString *)identifier
didUpdateProperties:(NSDictionary *)properties {
    SKComponentNode *sprite = _spriteNodes[identifier];
    if (properties[@"x"])
    {
        sprite.position = CGPointMake([properties[@"x"] floatValue], sprite.position.y);
    }
    if (properties[@"y"])
    {
        sprite.position = CGPointMake(sprite.position.x, [properties[@"y"] floatValue]);
    }
    if (properties[@"text"]) {
        
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
    
}

@end
