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
        self.name = @"world";
        
        _interpreter   = [ZSInterpreter interpreter];
        _spriteNodes   = [[NSMutableDictionary alloc] init];
        
        _interpreter.delegate = self;
        
        [self setupInterpreterWithProjectJSON:projectJSON];

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
            
            ZSSpriteTouchComponent *touchComponent = [ZSSpriteTouchComponent new];
            touchComponent.spriteId = object[@"id"];
            
            touchComponent.touchesBegan = ^(UITouch *touch) {
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
            
            };
             
            [node addComponent:touchComponent];
            [self addChild:node];

        }];
    }
    return self;
}

-(BOOL) spriteWithinWorld:(CGPoint)point size:(CGSize)size node:(ZSComponentNode *)node
{
    CGPoint midPointOfScene = CGPointMake(self.size.width / 2.0f, self.size.height / 2.0f);
    
    CGFloat xLeftBound =point.x - size.width / 2.0f;
    CGFloat xRightBound =point.x + size.width / 2.0f;
    
    NSLog(@"left side %f", xLeftBound);
    NSLog(@"right side %f", xRightBound);
    NSLog(@"point touched in sprite %@", NSStringFromCGPoint(point));
    
    if(point.x <= midPointOfScene.x)
    {
        if((point.x - size.width / 2.0f) > 0.0f)
        {
            return YES;
        }
    }
    else if(point.x > midPointOfScene.x)
    {
        if((point.x + size.width / 2.0f) < self.size.width)
        {
            return YES;
        }
    }
        return NO;
}

- (void) setupInterpreterWithProjectJSON:(NSDictionary *)projectJSON {
        ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:projectJSON];
        [self loadMethodsIntoInterpreter:_interpreter];
        [_interpreter runJSON:compiler.compiledJSON];
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
    
}

- (void)didSimulatePhysics {
    [self enumerateChildNodesWithName:kZSSpriteName
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               SKComponentNode *componentNode = (SKComponentNode *)node;
                               ZSSpriteTouchComponent *touchNode = [componentNode getComponent:[ZSSpriteTouchComponent class]];
                               
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
    ZSComponentNode *node = _spriteNodes[identifier];
    [self addParticle:identifier position:node.position duration:0.15f particleType:@"BrickExplosion"];
    [self removeSpriteNode:identifier];
    [_interpreter removeObjectWithIdentifier:identifier];
}

- (void)removeSpriteNode:(NSString *)identifier {
    SKSpriteNode *node = _spriteNodes[identifier];
    [node removeFromParent];
    [_spriteNodes removeObjectForKey:identifier];
}

- (void)addParticle:(NSString *)identifier
            position:(CGPoint)position
            duration:(float)duration
            particleType:(NSString *)particleType{
    
    //TODO make path generic
    NSString *burstPath =
    [[NSBundle mainBundle]
     pathForResource:particleType ofType:@"sks"];
    
    SKEmitterNode *burstNode =
    [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    
    burstNode.position = CGPointMake(position.x, position.y);
    
    [self addChild:burstNode];
    APARunOneShotEmitter(burstNode, duration);
}

void APARunOneShotEmitter(SKEmitterNode *emitter, CGFloat duration) {
    [emitter runAction:[SKAction sequence:@[
                                            [SKAction waitForDuration:duration],
                                            [SKAction runBlock:^{
        emitter.particleBirthRate = 0;
    }],
                                            [SKAction waitForDuration:emitter.particleLifetime + emitter.particleLifetimeRange],
                                            [SKAction removeFromParent],
                                            ]]];
}

- (void)interpreter:(ZSInterpreter *)interpreter
        objectWithIdentifier:(NSString *)identifier
        didUpdateProperties:(NSDictionary *)properties {
    ZSComponentNode *node = _spriteNodes[identifier];
    
    if (properties[@"x"]) {
        CGPoint point = CGPointMake([properties[@"x"] floatValue], node.position.y);
        SKSpriteNode *sprite = node.children.firstObject;
        CGSize size = sprite.size;
        
        if([self spriteWithinWorld:point size:size node:node])
        {
            node.position = CGPointMake([properties[@"x"] floatValue], node.position.y);
        }
//        node.position = CGPointMake([properties[@"x"] floatValue], node.position.y);
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
