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
@property (nonatomic) NSDictionary *categoryBitMasks;
@property (nonatomic) NSDictionary *collisionBitMasks;

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
        _categoryBitMasks = [[NSDictionary alloc] init];
        _collisionBitMasks = [[NSDictionary alloc] init];
        
        _interpreter.delegate = self;
        
        [self setupInterpreterWithProjectJSON:projectJSON];

        _categoryBitMasks = [self categoryBitMasksForCollisionGroups:projectJSON[@"groups"]];
        _collisionBitMasks = [self collisionBitMasksForCollisionGroups:projectJSON[@"groups"] categoryBitMasks:_categoryBitMasks];
        
        [projectJSON[@"objects"] each:^(NSDictionary *object) {
            
            NSDictionary *properties = object[@"properties"];
            
            CGPoint position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
            CGSize size      = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
            
            ZSComponentNode *node = [ZSComponentNode node];
            node.identifier = object[@"id"];
            node.name = kZSSpriteName;
            node.position = position;
            node.collisionGroup = object[@"group"];
            node.size = size;
            
            SKNode *childNode = [self childNodeForObjectJSON:object size:size];
            [node addChild:childNode];
            
            if(!_spriteNodes[object[@"id"]]) {
                _spriteNodes[object[@"id"]] = node;
            }
            
            node.physicsBody = [self physicsBodyForType:object[@"physics_body"] size:size];
            
            if (node.physicsBody) {
                node.physicsBody.categoryBitMask    = [_categoryBitMasks[object[@"group"]] integerValue];
                node.physicsBody.collisionBitMask   = [_collisionBitMasks[object[@"group"]] integerValue];
                node.physicsBody.contactTestBitMask = [_collisionBitMasks[object[@"group"]] integerValue];
                
                node.physicsBody.dynamic = NO;
                node.physicsBody.mass    = 0.02;
                node.physicsBody.affectedByGravity = NO;
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

- (SKPhysicsBody *)physicsBodyForType:(NSString *)type size:(CGSize)size {
    if ([type isEqualToString:@"circle"]) {
        return [SKPhysicsBody bodyWithCircleOfRadius:(size.width / 2)];
    } else if ([type isEqualToString:@"rectangle"]) {
        return [SKPhysicsBody bodyWithRectangleOfSize:size];
    }
    
    return nil;
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
    ZSComponentNode *node = _spriteNodes[identifier];
    ZSSpriteTouchComponent *component = [node getComponent:[ZSSpriteTouchComponent class]];
    component.speed = speed;
    CGFloat rad = direction * M_PI / 180;
    node.velocity = CGVectorMake(cosf(rad) * speed, -sinf(rad) * speed);
}

- (void)didSimulatePhysics {
    [self enumerateChildNodesWithName:kZSSpriteName
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               ZSComponentNode *componentNode = (ZSComponentNode *)node;
                               ZSSpriteTouchComponent *touchNode = [componentNode getComponent:[ZSSpriteTouchComponent class]];
                               
                               GLKVector2 velocity = GLKVector2Make(componentNode.velocity.dx, componentNode.velocity.dy);
                               GLKVector2 direction = GLKVector2Normalize(velocity);
                               GLKVector2 newVelocity = GLKVector2MultiplyScalar(direction, touchNode.speed);
                               node.physicsBody.velocity = CGVectorMake(newVelocity.x, newVelocity.y);
                               
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

- (BOOL)withinParentFrame:(CGPoint)point size:(CGSize)size
{
    CGFloat offsetx = size.width / 2.0f;
    CGFloat offsety = size.height / 2.0f;
    if(point.x >= offsetx && point.x <= self.scene.frame.size.width - offsetx &&
       point.y >= offsety && point.y <= self.scene.frame.size.height - offsety)
        return YES;
    return NO;
}

- (void)interpreter:(ZSInterpreter *)interpreter
        objectWithIdentifier:(NSString *)identifier
        didUpdateProperties:(NSDictionary *)properties {
    ZSComponentNode *node = _spriteNodes[identifier];
    
    if (properties[@"x"]) {
        CGPoint point = CGPointMake([properties[@"x"] floatValue], node.position.y);
        CGPoint movePoint = CGPointMake(point.x, node.position.y);
        
        CGFloat offsetx = node.size.width / 2.0f;
        if([self withinParentFrame:movePoint size:node.size])
        {
            node.position = movePoint;
        }
        else {
            if (movePoint.x < offsetx) {
                movePoint.x = offsetx;
            }
            if (movePoint.x > self.scene.frame.size.width - offsetx) {
                movePoint.x = self.scene.frame.size.width - offsetx;
            }
            node.position = movePoint;
        }
        
    }
    if (properties[@"y"]) {
        CGPoint point = CGPointMake(node.position.x, [properties[@"y"] floatValue]);
        CGPoint movePoint = CGPointMake(node.position.x, point.y);
        
        CGFloat offsety = node.size.height / 2.0f;
        if([self withinParentFrame:movePoint size:node.size])
        {
            node.position = movePoint;
        }
        else {
            if (movePoint.y < offsety) {
                movePoint.y = offsety;
            }
            if (movePoint.y > self.scene.frame.size.height - offsety) {
                movePoint.y = self.scene.frame.size.height - offsety;
            }
            node.position = movePoint;
        }
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
    
    [self detectSpriteCollision];
    [self updateSpritePositions:self.lastUpdateTimeInterval];
}

- (void)detectSpriteCollision
{
    NSMutableDictionary *tempSprites = [[NSMutableDictionary alloc] init];
    for (id key in _spriteNodes)
    {
        if([_spriteNodes[key] isKindOfClass:[ZSComponentNode class]])
        {
            ZSComponentNode *node = _spriteNodes[key];
            if ([_collisionBitMasks objectForKey:node.collisionGroup])
                 tempSprites[key] = _spriteNodes[key];
        }
    }
    
    for (id key in _spriteNodes)
    {
        if([_spriteNodes[key] isKindOfClass:[ZSComponentNode class]])
        {
            ZSComponentNode *node = _spriteNodes[key];
            if (![_collisionBitMasks objectForKey:node.collisionGroup])
                continue;
        
            [tempSprites removeObjectForKey:key];
        
            for (id tempKey in tempSprites)
            {
                id collisionBitMask = _collisionBitMasks[node.collisionGroup];
            
//                if (cg.contains(temp_sprites[q].collision_group) && s.collidesWith(temp_sprites[q]))
//                {
//                    s.resolveCollisionWith(temp_sprites[q]);
//                    this.interpreter.triggerEventOnObjectWithParameters("collision", s.id, { other_sprite: temp_sprites[q].id });
//                    this.interpreter.triggerEventOnObjectWithParameters("collision", temp_sprites[q].id, { other_sprite: s.id });
//                }
            }
        }
    }
}

- (void)updateSpritePositions:(CFTimeInterval)dt
{
    for (id key in _spriteNodes)
    {
        if(![_spriteNodes[key] isKindOfClass:[ZSComponentNode class]])
             continue;
             
        ZSComponentNode *node = _spriteNodes[key];
        CGPoint oldPosition = node.position;
        
        [node updatePosition:dt];
        
        if (![self withinParentFrame:node.position size:node.size])
            node.position = oldPosition;
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
