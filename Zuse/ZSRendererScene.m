//
//  ZSRendererScene.m
//  Zuse
//
//  Created by Sarah Hong on 10/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <SpriteKit-Components/SKComponents.h>
#import "ZSComponentNode.h"
#import "BlocksKit.h"
@import GLKit;

#import "ZSRendererScene.h"
#import "ZSSpriteTouchComponent.h"
#import "ZSCompiler.h"

#import "NSString+Zuse.h"
#import "NSNumber+Zuse.h"


@interface ZSRendererScene() <ZSInterpreterDelegate>

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSMutableDictionary *spriteNodes;
@property (nonatomic) NSMutableDictionary *movingSprites;
@property (nonatomic) NSMutableDictionary *jointNodes;
@property (strong, nonatomic) ZSInterpreter *interpreter;
@property (nonatomic) NSMutableDictionary *physicsJoints;

@end

NSString * const kZSSpriteName = @"sprite";
NSString * const kZSJointName = @"joint";
//CGFloat const kZSSpriteSpeed = 200;

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory)
{
	GFPhysicsCategoryWorld  = 1 << 0
};

@implementation ZSRendererScene

-(id)initWithSize:(CGSize)size projectJSON:(NSDictionary *)projectJSON {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor whiteColor];
        
        _interpreter   = [ZSInterpreter interpreter];
        _physicsJoints = [[NSMutableDictionary alloc] init];
        _spriteNodes   = [[NSMutableDictionary alloc] init];
        _jointNodes    = [[NSMutableDictionary alloc] init];
        
        _interpreter.delegate = self;
        
        [self setupInterpreterWithProjectJSON:projectJSON];
        [self setupWorldPhysics];

        NSDictionary *categoryBitMasks = [self categoryBitMasksForCollisionGroups:projectJSON[@"collision_groups"]];
        NSDictionary *collisionBitMasks = [self collisionBitMasksForCollisionGroups:projectJSON[@"collision_groups"] categoryBitMasks:categoryBitMasks];
        
        [projectJSON[@"objects"] each:^(NSDictionary *object) {
            
            NSDictionary *properties = object[@"properties"];
            
            CGPoint position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            CGSize size      = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
        
            
            ZSComponentNode *node = [ZSComponentNode node];
            node.identifier = object[@"id"];
            node.name = kZSSpriteName;
            node.position = position;
            
            SKNode *childNode = [self childNodeForObjectJSON:object size:size];
            [node addChild:childNode];
            
            if(!_spriteNodes[object[@"id"]]) {
                _spriteNodes[object[@"id"]] = node;
            }
            
            node.physicsBody = [self physicsBodyForType:object[@"physics_body"] size:size];
            
            if (node.physicsBody) {
                node.physicsBody.categoryBitMask    = [categoryBitMasks[object[@"collision_group"]] integerValue];
                node.physicsBody.collisionBitMask   = [collisionBitMasks[object[@"collision_group"]] integerValue];
                node.physicsBody.contactTestBitMask = [collisionBitMasks[object[@"collision_group"]] integerValue];
                
                node.physicsBody.dynamic = NO;
                node.physicsBody.mass    = 0.02;
                node.physicsBody.affectedByGravity = NO;
            }
            
            ZSSpriteTouchComponent *touchComponent = [ZSSpriteTouchComponent new];
            touchComponent.spriteId = object[@"id"];
            
            
            touchComponent.touchesBegan = ^(UITouch *touch) {
                if (node.physicsBody) {
                    node.physicsBody.dynamic = YES;
                    
                    [self removeJointNode:object[@"id"]];
                    [self removePhysicsJoint:object[@"id"]];
                    
                    ZSComponentNode *jointNode = [ZSComponentNode node];
                    jointNode.name     = kZSJointName;
                    jointNode.position = node.position;
                    
                    jointNode.physicsBody = [self physicsBodyForType:object[@"physics_body"] size:size];
                    [self configureJointNodePhysics:jointNode];
                    
                    _jointNodes[object[@"id"]] = jointNode;
                    [self addChild:jointNode];
                    
                    SKSpriteNode *jointSprite = [SKSpriteNode new];
//                    SKSpriteNode *jointSprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
                    jointSprite.size = size;
                    [jointNode addChild:jointSprite];
                    
                    SKPhysicsJointFixed *fixedJoint = [SKPhysicsJointFixed jointWithBodyA:node.physicsBody
                                                                                    bodyB:jointNode.physicsBody
                                                                                   anchor:node.position];
                    [self.physicsWorld addJoint:fixedJoint];
                    _physicsJoints[object[@"id"]] = fixedJoint;
                    
                    NSLog(@"node has physics body");
                }
                else{
                    NSLog(@"node has no physics body");
                }
                
                CGPoint point = [touch locationInNode:self];
                
                [_interpreter triggerEvent:@"touch_began"
                    onObjectWithIdentifier:object[@"id"]
                                parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            
            touchComponent.touchesMoved = ^(UITouch *touch) {
                CGPoint point = [touch locationInNode:self];
                
                [_interpreter triggerEvent:@"touch_moved"
                        onObjectWithIdentifier:object[@"id"]
                                    parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
            };
            
            touchComponent.touchesEnded = ^(UITouch *touch) {
                if (node.physicsBody) {
                    
                    //remove the physics joint once the touch event ends
                    [self removePhysicsJoint:object[@"id"]];
                    [self removeJointNode:object[@"id"]];
                    node.physicsBody.dynamic = NO;
                }
            };
             
            [node addComponent:touchComponent];
            [self addChild:node];

        }];
    }
    return self;
}

- (void) setupInterpreterWithProjectJSON:(NSDictionary *)projectJSON {
        ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:projectJSON];
        [self loadMethodsIntoInterpreter:_interpreter];
        [_interpreter runJSON:compiler.compiledJSON];
}

- (void) setupWorldPhysics {
    //Set the physics edges to the frame
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = GFPhysicsCategoryWorld;
    //set up the scene as the contact delegate
    self.physicsWorld.contactDelegate = self;
}

- (NSDictionary *) categoryBitMasksForCollisionGroups:(NSDictionary *)collisionGroups {
    NSInteger categoryBitMaskCount = 1;
    NSMutableDictionary *categoryBitMasks = [NSMutableDictionary dictionary];
    for(id key in collisionGroups){
        uint32_t categoryBitMask = 1 << categoryBitMaskCount++;
        categoryBitMasks[key] = @(categoryBitMask);
        NSLog(@"category bitmask for %@: %@", key, binaryStringFromInteger(categoryBitMask));
    }
    
    return categoryBitMasks;
}

- (NSDictionary *)collisionBitMasksForCollisionGroups:(NSDictionary *)collisionGroups
                                     categoryBitMasks:(NSDictionary *)categoryBitMasks {
    
    NSMutableDictionary *collisionBitMasks = [NSMutableDictionary dictionary];
    for (id key in collisionGroups) {
        uint32_t collisionBitMask = 1;
        for (NSString *group in collisionGroups[key]) {
            collisionBitMask |= [categoryBitMasks[group] intValue];
        }
        collisionBitMasks[key] = @(collisionBitMask);
        NSLog(@"collision bitmask for %@: %@", key, binaryStringFromInteger(collisionBitMask));
    }
    
    return collisionBitMasks;
}

- (SKPhysicsBody *)physicsBodyForType:(NSString *)type size:(CGSize)size {
    if ([type isEqualToString:@"circle"]) {
        return [SKPhysicsBody bodyWithCircleOfRadius:(size.width / 2)];
    } else if ([type isEqualToString:@"rectangle"]) {
        return [SKPhysicsBody bodyWithRectangleOfSize:size];
    }
    
    return nil;
}

- (SKNode *)childNodeForObjectJSON:(NSDictionary *)object size:(CGSize)size {
    SKNode *node = nil;
            if ([object[@"type"] isEqualToString:@"image"]) {
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
                sprite.size = size;
                node = sprite;
            }
            else if ([object[@"type"] isEqualToString:@"text"]) {
                SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                labelNode.name = @"Text";
                labelNode.text = object[@"properties"][@"text"];
                labelNode.fontColor = [SKColor blackColor];
                labelNode.fontSize = 30;
                labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                node = labelNode;
            }
    
    if (!node) {
        @throw [NSString stringWithFormat:@"ZSRendererScene#childNodeForObjectJSON:size: - attempted to create unknown node type %@", object[@"image"][@"path"]];
    }
    
    return node;
}

- (void)configureJointNodePhysics:(ZSComponentNode *)jointNode {
    //set the joint to not collide with anything
    jointNode.physicsBody.categoryBitMask = 0;
    jointNode.physicsBody.dynamic = NO;
    jointNode.physicsBody.mass = 0.02;
    jointNode.physicsBody.velocity = CGVectorMake(0, 0);
    jointNode.physicsBody.affectedByGravity = NO;
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask != GFPhysicsCategoryWorld &&
        contact.bodyB.categoryBitMask != GFPhysicsCategoryWorld) {
        
        ZSComponentNode *nodeA = (ZSComponentNode *)contact.bodyA.node;
        ZSComponentNode *nodeB = (ZSComponentNode *)contact.bodyB.node;
        
        [_interpreter triggerEvent:@"collision"
            onObjectWithIdentifier:nodeA.identifier];
        [_interpreter triggerEvent:@"collision"
            onObjectWithIdentifier:nodeB.identifier];
        
        NSLog(@"%@", nodeA.identifier);
        NSLog(@"%@", nodeB.identifier);
        NSLog(@"");
    }
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
    [self removePhysicsJoint:identifier];
    [self removeJointNode:identifier];
    [self removeSpriteNode:identifier];
    [_interpreter removeObjectWithIdentifier:identifier];
}

- (void)removeSpriteNode:(NSString *)identifier {
    SKSpriteNode *node = _spriteNodes[identifier];
    [node removeFromParent];
    [_spriteNodes removeObjectForKey:identifier];
}

- (void)removeJointNode:(NSString *)identifier{
    ZSComponentNode *jointNode = _jointNodes[identifier];
    if (jointNode) {
        [jointNode removeFromParent];
        [_jointNodes removeObjectForKey:identifier];
    }
}

- (void)removePhysicsJoint:(NSString *)identifier{
    SKPhysicsJoint *joint = _physicsJoints[identifier];
    if (joint) {
        [self.physicsWorld removeJoint:joint];
        [_physicsJoints removeObjectForKey:identifier];
    }
}

- (void)interpreter:(ZSInterpreter *)interpreter
        objectWithIdentifier:(NSString *)identifier
        didUpdateProperties:(NSDictionary *)properties {
    ZSComponentNode *node = _spriteNodes[identifier];
    if (properties[@"x"]) {
        ZSComponentNode *joint = _jointNodes[identifier];
        if (joint)
            node = joint;
        node.position = CGPointMake([properties[@"x"] floatValue], node.position.y);
    }
    if (properties[@"y"]) {
        ZSComponentNode *joint = _jointNodes[identifier];
        if (joint)
            node = joint;
        node.position = CGPointMake(node.position.x, [properties[@"y"] floatValue]);
    }
    if (properties[@"text"]) {
        SKLabelNode *textNode = [node.children match:^BOOL(id obj) {
            return [obj isKindOfClass:SKLabelNode.class];
        }];
        if (textNode) {
            textNode.text = [properties[@"text"] coercedString];
        }
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

NSString * binaryStringFromInteger( int number )
{
    NSMutableString * string = [[NSMutableString alloc] init];
    
    int spacing = pow( 2, 3 );
    int width = ( sizeof( number ) ) * spacing;
    int binaryDigit = 0;
    int integer = number;
    
    while( binaryDigit < width )
    {
        binaryDigit++;
        
        [string insertString:( (integer & 1) ? @"1" : @"0" )atIndex:0];
        
        if( binaryDigit % spacing == 0 && binaryDigit != width )
        {
            [string insertString:@" " atIndex:0];
        }
        
        integer = integer >> 1;
    }
    
    return string;
}

@end
