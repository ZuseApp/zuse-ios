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
@property (nonatomic) NSMutableDictionary *activeJointNodes;
@property (strong, nonatomic) ZSInterpreter *interpreter;
@property (nonatomic) NSMutableDictionary *physicsJoints;

@end

NSString * const kZSSpriteName = @"sprite";
NSString * const kZSJointName = @"joint";
CGFloat const kZSSpriteSpeed = 200;
CGPoint kZSSpritePosition;

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
        _physicsJoints = [[NSMutableDictionary alloc] init];
        _spriteNodes = [[NSMutableDictionary alloc] init];
        
        //create category bit masks for each group of sprites
        
        NSInteger categoryBitMaskCount = 1;
        NSMutableDictionary *categoryBitMasks = [NSMutableDictionary dictionary];
        NSMutableDictionary *collisionBitMasks = [NSMutableDictionary dictionary];
        NSDictionary *collisionGroups = projectJSON[@"collision_groups"];
        
        for(id key in collisionGroups){
            uint32_t categoryBitMask = 1 << categoryBitMaskCount++;
            categoryBitMasks[key] = @(categoryBitMask);
            NSLog(@"category bitmask for %@: %@", key, binaryStringFromInteger(categoryBitMask));
        }
        
        for (id key in collisionGroups) {
            uint32_t collisionBitMask = 1;
            for (NSString *group in collisionGroups[key]) {
                collisionBitMask |= [categoryBitMasks[group] intValue];
            }
            collisionBitMasks[key] = @(collisionBitMask);
            NSLog(@"collision bitmask for %@: %@", key, binaryStringFromInteger(collisionBitMask));
        }
        
        [projectJSON[@"objects"] each:^(NSDictionary *object) {
            
            NSDictionary *properties = object[@"properties"];
            kZSSpritePosition = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            
            CGPoint position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            CGSize size = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
        
            
            ZSComponentNode *node = [ZSComponentNode node];
            node.identifier = object[@"id"];
            node.name = kZSSpriteName;
            node.position = position;
            
            //set up the sprite size and position on screen
            
            if ([object[@"type"] isEqualToString:@"image"]) {
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
                sprite.size = size;
                [node addChild:sprite];
            }
            else if ([object[@"type"] isEqualToString:@"text"]) {
                SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                labelNode.name = @"Text";
                labelNode.text = properties[@"text"];
                labelNode.fontColor = [SKColor blackColor];
                labelNode.fontSize = 30;
                labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
                labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                [node addChild:labelNode];
            }
            
            node.position = position;
            
            //add sprite to the node
            if(!_spriteNodes[object[@"id"]])
            {
                _spriteNodes[object[@"id"]] = node;
            }
            
            //add the node as a physics body for physics debugging
            SKComponentNode *jointNode = [SKComponentNode new];
            jointNode.position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            jointNode.alpha =1.0;
            //set the joint to not collide with anything
            jointNode.physicsBody.categoryBitMask = 0;
            jointNode.name = kZSJointName;
            //make a transparent sprite for the joint with the same dimensions as the node's sprite
            SKSpriteNode *jointSprite = [SKSpriteNode new];

//            SKSpriteNode *jointSprite = [SKSpriteNode spriteNodeWithImageNamed:object[@"image"][@"path"]];
            jointSprite.size = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
            [jointNode addChild:jointSprite];
            [_jointNodes setObject:jointNode forKey:object[@"id"]];
            
            if ([object[@"physics_body"] isEqualToString:@"circle"]) {
                node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(size.width / 2)];

            } else if ([object[@"physics_body"] isEqualToString:@"rectangle"]) {
                node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
            }
            
            if (node.physicsBody) {
                node.physicsBody.categoryBitMask = [categoryBitMasks[object[@"collision_group"]] integerValue];
                node.physicsBody.collisionBitMask = [collisionBitMasks[object[@"collision_group"]] integerValue];
                node.physicsBody.contactTestBitMask = [collisionBitMasks[object[@"collision_group"]] integerValue];
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
                node.physicsBody.dynamic = YES;
                
                SKComponentNode *jointNode = _jointNodes[object[@"id"]];
                _activeJointNodes[object[@"id"]] = jointNode;
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
                node.physicsBody.dynamic = NO;
                
                //set the the last touch for the joint node
                SKComponentNode *jointNode = _jointNodes[object[@"id"]];
                [_activeJointNodes removeObjectForKey:object[@"id"]];
                
                jointNode.position = node.position;
                //remove the physics joint once the touch event ends
                [self removePhysicsJoint:object[@"id"]];
                [self removeJointNode:object[@"id"]];
            };
             
            [node addComponent:touchComponent];
            
            node.physicsBody.dynamic = NO;
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
    if (contact.bodyA.categoryBitMask != GFPhysicsCategoryWorld &&
        contact.bodyB.categoryBitMask != GFPhysicsCategoryWorld) {
        
        [_interpreter triggerEvent:@"collision"
            onObjectWithIdentifier:((ZSComponentNode *)contact.bodyA.node).identifier];
        [_interpreter triggerEvent:@"collision"
            onObjectWithIdentifier:((ZSComponentNode *)contact.bodyB.node).identifier];
        
        NSLog(@"%@", ((ZSComponentNode *)contact.bodyA.node).identifier);
        NSLog(@"%@", ((ZSComponentNode *)contact.bodyB.node).identifier);
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
    SKComponentNode *node = _spriteNodes[identifier];
    if (properties[@"x"])
    {
        SKComponentNode *sprite = _jointNodes[identifier];
        if (!sprite)
            sprite = node;
        sprite.position = CGPointMake([properties[@"x"] floatValue], sprite.position.y);
    }
    if (properties[@"y"])
    {
        SKComponentNode *sprite = _jointNodes[identifier];
        if (!sprite)
            sprite = node;
        sprite.position = CGPointMake(sprite.position.x, [properties[@"y"] floatValue]);
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
