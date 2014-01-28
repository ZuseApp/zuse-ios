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
@property (nonatomic) NSMutableDictionary *movingSprites;
@property (nonatomic) NSMutableDictionary *jointNodes;
@property (nonatomic) NSMutableDictionary *categoryBitMasks;
@property (strong, nonatomic) ZSInterpreter *interpreter;
@property (nonatomic) NSMutableDictionary *physicsJoints;

@end

NSString * const kZSSpriteName = @"sprite";
NSString * const kZSJointName = @"joint";
CGFloat const kZSSpriteSpeed = 200;
CGPoint kZSSpritePosition;
NSInteger categoryBitMaskCount = 1;

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
	GFPhysicsCategoryWorld  = 1 << 0
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
        //set up the scene as the contact delegate
        self.physicsWorld.contactDelegate = self;

        _jointNodes = [[NSMutableDictionary alloc] init];
        _categoryBitMasks = [[NSMutableDictionary alloc] init];
        _physicsJoints = [[NSMutableDictionary alloc] init];

        _spriteNodes = [[NSMutableDictionary alloc] init];
        
        [projectJSON[@"objects"] each:^(NSDictionary *object) {
            
            NSDictionary *properties = object[@"properties"];
            kZSSpritePosition = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            
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
            if(!_spriteNodes[object[@"id"]])
            {
                _spriteNodes[object[@"id"]] = node;
            }
            
            //add the node as a physics body for physics debugging
            SKComponentNode *jointNode = [SKComponentNode new];
            jointNode.position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            jointNode.alpha =1.0;

            jointNode.name = kZSJointName;
            //make a transparent sprite for the joint with the same dimensions as the node's sprite
//            SKSpriteNode *jointSprite = [SKSpriteNode new];

            SKSpriteNode *jointSprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
            jointSprite.size = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
            [jointNode addChild:jointSprite];
            [_jointNodes setObject:jointNode forKey:object[@"id"]];
            
            if(!_categoryBitMasks[object[@"id"]])
            {
                uint32_t categoryBitMask = 1 << categoryBitMaskCount++;
                _categoryBitMasks[object[@"id"]] = @(categoryBitMask);
            }
            
            if ([object[@"physics_body"] isEqualToString:@"circle"]) {
                node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(sprite.size.width / 2)];
                node.physicsBody.categoryBitMask = [_categoryBitMasks[object[@"id"]] integerValue];
                node.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
                jointNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(sprite.size.width / 2)];
                jointNode.physicsBody.categoryBitMask = 0;

            } else {
                node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
                node.physicsBody.categoryBitMask = [_categoryBitMasks[object[@"id"]] integerValue];
                node.physicsBody.collisionBitMask = GFPhysicsCategoryWorld;
                jointNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
                jointNode.physicsBody.categoryBitMask = 0;
            }
            
            ZSSpriteTouchComponent *touchComponent = [ZSSpriteTouchComponent new];
            touchComponent.spriteId = object[@"id"];
            
            touchComponent.touchesMoved = ^(UITouch *touch) {
                CGPoint point = [touch locationInNode:self];
                
                SKComponentNode *jointNode = _jointNodes[object[@"id"]];
                
                if(jointNode.position.x < 0.0 || jointNode.position.x > self.size.width)
                {
                    jointNode.position = node.position;
                    point = jointNode.position;
                    point.x += 2.0;
                }
                
                    [_interpreter triggerEvent:@"touch_moved"
                        onObjectWithIdentifier:object[@"id"]
                                    parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
                
            };
            
            touchComponent.touchesBegan = ^(UITouch *touch) {
                SKComponentNode *jointNode = _jointNodes[object[@"id"]];
                //set up the physics of the joint node.
                jointNode.physicsBody.dynamic = NO;
                jointNode.physicsBody.mass = 0.02;
                jointNode.physicsBody.velocity = CGVectorMake(0, 0);
                jointNode.physicsBody.affectedByGravity = NO;
                [self removeJointNode:object[@"id"]];
                //add the joint node to the scene
                [self addChild:jointNode];
                
                //create the physics joint
                SKPhysicsJointFixed *physicsJointFixed = [SKPhysicsJointFixed jointWithBodyA:node.physicsBody bodyB:jointNode.physicsBody anchor:node.position];
                [self.physicsWorld addJoint:physicsJointFixed];
                _physicsJoints[object[@"id"]] = physicsJointFixed;
                
                CGPoint point = [touch locationInNode:self];
                
                [_interpreter triggerEvent:@"touch_began"
                    onObjectWithIdentifier:object[@"id"]
                                parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            
            touchComponent.touchesEnded = ^(UITouch *touch) {
                //set the the last touch for the joint node
                SKComponentNode *jointNode = _jointNodes[object[@"id"]];
                
                jointNode.position = node.position;
                //remove the physics joint once the touch event ends
                [self removePhysicsJoint:object[@"id"]];
                [self removeJointNode:object[@"id"]];
            };
             
            [node addComponent:touchComponent];
            
            node.physicsBody.dynamic = YES;
            node.physicsBody.mass = 0.02;
            node.physicsBody.affectedByGravity = NO;

            //add both nodes to scene
            [self addChild:node];

        }];
        
        // setting background color
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    return self;
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    
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
    [self enumerateChildNodesWithName:kZSSpriteName
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               NSLog(@"running");
                               SKComponentNode *componentNode = (SKComponentNode *)node;
                               ZSSpriteTouchComponent *touchNode = [componentNode getComponent:[ZSSpriteTouchComponent class]];
                               if(node.physicsBody.velocity.dx == 0 || node.physicsBody.velocity.dy == 0)
                               {
                                   return;
                               }
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
    
    [self removeJointNode:identifier];
    [self removeSpriteNode:identifier];
    [self removePhysicsJoint:identifier];
    [_interpreter removeObjectWithIdentifier:identifier];
}

- (void)removeSpriteNode:(NSString *)identifier {
    SKSpriteNode *node = _spriteNodes[identifier];
    [node removeFromParent];
    [_spriteNodes removeObjectForKey:identifier];
}

- (void)removeJointNode:(NSString *)identifier{
    SKSpriteNode *jointNode = _jointNodes[identifier];
    [jointNode removeFromParent];
}

- (void)removePhysicsJoint:(NSString *)identifier{
    [self.physicsWorld removeJoint:_physicsJoints[identifier]];
    [_physicsJoints removeObjectForKey:identifier];
}

- (void)interpreter:(ZSInterpreter *)interpreter
        objectWithIdentifier:(NSString *)identifier
        didUpdateProperties:(NSDictionary *)properties {
    SKComponentNode *sprite = _jointNodes[identifier];
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
