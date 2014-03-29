//
//  ZSRendererScene.m
//  Zuse
//
//  Created by Sarah Hong on 10/25/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

@import GLKit;

#import <SpriteKit-Components/SKComponents.h>
#import <mach/mach_time.h>
#import "ZSComponentNode.h"
#import "BlocksKit.h"
#import "ZSRendererScene.h"
#import "ZSSpriteTouchComponent.h"
#import "ZSCompiler.h"
#import "NSString+Zuse.h"
#import "NSNumber+Zuse.h"
#import "ZSTimedEvent.h"


@interface ZSRendererScene() <ZSInterpreterDelegate>

@property (assign, nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (strong, nonatomic) NSMutableDictionary *spriteNodes;
@property (strong, nonatomic) NSMutableDictionary *movingSprites;
@property (strong, nonatomic) NSMutableDictionary *jointNodes;
@property (strong, nonatomic) ZSInterpreter *interpreter;
@property (strong, nonatomic) NSMutableDictionary *physicsJoints;
@property (strong, nonatomic) NSDictionary *projectJSON;
@property (strong, nonatomic) NSDictionary *categoryBitMasks;
@property (strong, nonatomic) NSDictionary *collisionBitMasks;
@property (strong, nonatomic) NSMutableArray *timedEvents;

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
        
        self.projectJSON   = projectJSON;
        self.interpreter   = [ZSInterpreter interpreter];
        self.physicsJoints = [NSMutableDictionary dictionary];
        self.spriteNodes   = [NSMutableDictionary dictionary];
        self.jointNodes    = [NSMutableDictionary dictionary];
        self.timedEvents   = [NSMutableArray array];
        
        self.interpreter.delegate = self;
        
        [self setupInterpreterWithProjectJSON:projectJSON];
        [self setupWorldPhysics];

        self.categoryBitMasks = [self categoryBitMasksForCollisionGroups:projectJSON[@"collision_groups"]];
        self.collisionBitMasks = [self collisionBitMasksForCollisionGroups:projectJSON[@"collision_groups"]
                                                          categoryBitMasks:self.categoryBitMasks];
        
        [projectJSON[@"objects"] each:^(NSDictionary *object) {
            [self addSpriteWithJSON:object];
        }];
    }
    return self;
}

- (void)addSpriteWithJSON:(NSDictionary *)spriteJSON {
    NSDictionary *properties = spriteJSON[@"properties"];
    
    CGPoint position = CGPointMake([properties[@"x"] floatValue], [properties[@"y"] floatValue]);
    CGSize size      = CGSizeMake([properties[@"width"] floatValue], [properties[@"height"] floatValue]);
    
    
    ZSComponentNode *node = [ZSComponentNode node];
    node.identifier = spriteJSON[@"id"];
    //            node.particleType = spriteJSON[@"particle_type"];
    node.name = kZSSpriteName;
    node.position = position;
    
    SKNode *childNode = [self childNodeForObjectJSON:spriteJSON size:size];
    [node addChild:childNode];
    
    if(!_spriteNodes[spriteJSON[@"id"]]) {
        _spriteNodes[spriteJSON[@"id"]] = node;
    }
    
    node.physicsBody = [self physicsBodyForType:spriteJSON[@"physics_body"] size:size];
    
    if (node.physicsBody) {
        node.physicsBody.categoryBitMask    = [self.categoryBitMasks[spriteJSON[@"collision_group"]] integerValue];
        node.physicsBody.collisionBitMask   = [self.collisionBitMasks[spriteJSON[@"collision_group"]] integerValue];
        node.physicsBody.contactTestBitMask = [self.collisionBitMasks[spriteJSON[@"collision_group"]] integerValue];
        
        node.physicsBody.dynamic = NO;
        node.physicsBody.mass    = 0.02;
        node.physicsBody.affectedByGravity = NO;
    }
    
    ZSSpriteTouchComponent *touchComponent = [ZSSpriteTouchComponent new];
    touchComponent.spriteId = spriteJSON[@"id"];
    
    touchComponent.touchesBegan = ^(UITouch *touch) {
        if (node.physicsBody) {
            node.physicsBody.dynamic = YES;
            
            [self removeJointNode:spriteJSON[@"id"]];
            [self removePhysicsJoint:spriteJSON[@"id"]];
            
            ZSComponentNode *jointNode = [ZSComponentNode node];
            jointNode.name     = kZSJointName;
            jointNode.position = node.position;
            
            jointNode.physicsBody = [self physicsBodyForType:spriteJSON[@"physics_body"] size:size];
            [self configureJointNodePhysics:jointNode];
            
            _jointNodes[spriteJSON[@"id"]] = jointNode;
            [self addChild:jointNode];
            
            SKSpriteNode *jointSprite = [SKSpriteNode new];
            //                    SKSpriteNode *jointSprite = [SKSpriteNode spriteNodeWithImageNamed:spriteJSON[@"image"][@"path"]];
            jointSprite.size = size;
            [jointNode addChild:jointSprite];
            
            SKPhysicsJointFixed *fixedJoint = [SKPhysicsJointFixed jointWithBodyA:node.physicsBody
                                                                            bodyB:jointNode.physicsBody
                                                                           anchor:node.position];
            [self.physicsWorld addJoint:fixedJoint];
            _physicsJoints[spriteJSON[@"id"]] = fixedJoint;
            
            NSLog(@"node has physics body");
        }
        else{
            NSLog(@"node has no physics body");
        }
        
        CGPoint point = [touch locationInNode:self];
        
        [_interpreter triggerEvent:@"touch_began"
            onObjectWithIdentifier:spriteJSON[@"id"]
                        parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
    };
    
    touchComponent.touchesMoved = ^(UITouch *touch) {
        CGPoint point = [touch locationInNode:self];
        
        [_interpreter triggerEvent:@"touch_moved"
            onObjectWithIdentifier:spriteJSON[@"id"]
                        parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
    };
    
    touchComponent.touchesEnded = ^(UITouch *touch) {
        if (node.physicsBody) {
            
            //remove the physics joint once the touch event ends
            [self removePhysicsJoint:spriteJSON[@"id"]];
            [self removeJointNode:spriteJSON[@"id"]];
            node.physicsBody.dynamic = NO;
        }
    };
    
    [node addComponent:touchComponent];
    [self addChild:node];
    

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
            onObjectWithIdentifier:nodeA.identifier parameters:@{ @"other_group": nodeB.identifier }];
        [_interpreter triggerEvent:@"collision"
            onObjectWithIdentifier:nodeB.identifier parameters:@{ @"other_group": nodeA.identifier }];
    } else {
        // TODO: Put in world collisions
    }
}

- (void)moveSpriteWithIdentifier:(NSString *)identifier
                       direction:(CGFloat)direction
                           speed:(CGFloat)speed {
    SKComponentNode *node = _spriteNodes[identifier];
    ZSSpriteTouchComponent *component = [node getComponent:[ZSSpriteTouchComponent class]];
    node.physicsBody.dynamic = YES;
    component.speed = speed;
    
    direction = ((direction) / 180.0 * M_PI);
    node.physicsBody.velocity = CGVectorMake(speed * cosf(direction), speed * sinf(direction));
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
    
    [interpreter loadMethod:@{
        @"method": @"every_seconds",
        @"block": ^id(NSString *identifier, NSArray *args) {
            NSInteger seconds = [args[0] integerValue];
            NSString *eventIdentifier = args[1];
            [self addTimerWithDuration:seconds
                      objectIdentifier:identifier
                       eventIdentifier:eventIdentifier];
            NSLog(@"%@", args);
            return nil;
        }
    }];
    
    // TODO: Move into own class
    [interpreter loadMethod:@{
        @"method": @"random_number",
        @"block": ^id(NSString *identifier, NSArray *args) {
            NSInteger low  = [[args[0] coercedNumber] integerValue];
            NSInteger high = [[args[1] coercedNumber] integerValue];
            return @((arc4random() % high) + low);
        }
    }];
    
    [interpreter loadMethod:@{
        @"method": @"generate",
        @"block": ^id(NSString *identifier, NSArray *args) {
            NSString *generatorIdentifier = args[0];
            NSNumber *x = args[1];
            NSNumber *y = args[2];
            NSMutableDictionary *object = [(NSDictionary *)[(NSArray *)self.projectJSON[@"generators"] match:^BOOL(NSDictionary *generator) {
                return [generator[@"name"] isEqualToString:generatorIdentifier];
            }] deepMutableCopy];
        
            NSLog(@"%@", generatorIdentifier);
        
            object[@"id"] = [NSUUID.UUID UUIDString];
            [object[@"properties"] addEntriesFromDictionary:@{ @"x": x, @"y": y }];
        
            NSArray *interpreterObjects = [ZSCompiler zuseIRObjectsFromDSLObjects:@[object]];
        
            NSDictionary *codeItem = @{ @"suite": interpreterObjects };
        
            [self.interpreter runJSON:codeItem];
        
            [self addSpriteWithJSON:object];
        
            [self.interpreter triggerEvent:@"start" onObjectWithIdentifier:object[@"id"]];
        
            return nil;
        }
    }];
}

- (void)addTimerWithDuration:(NSInteger)seconds
            objectIdentifier:(NSString *)objectIdentifier
             eventIdentifier:(NSString *)eventIdentifier {
    ZSTimedEvent *event = [[ZSTimedEvent alloc] init];
    event.interval = seconds;
    event.nextTime = [[NSDate date] timeIntervalSinceReferenceDate];
    event.eventIdentifier = eventIdentifier;
    event.objectIdentifier = objectIdentifier;
    
    [self.timedEvents addObject:event];
}

- (void)removeSpriteWithIdentifier:(NSString *)identifier {
    ZSComponentNode *node = _spriteNodes[identifier];
    [self addParticle:identifier position:node.position duration:0.15f particleType:@"BrickExplosion"];
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

- (BOOL)interpreter:(ZSInterpreter *)interpreter shouldDelegateProperty:(NSString *)property objectIdentifier:(NSString *)identifier {
    return [@[@"x", @"y"] indexOfObject:property] != NSNotFound;
}

- (id)interpreter:(ZSInterpreter *)interpreter valueForProperty:(NSString *)property objectIdentifier:(NSString *)identifier {
    ZSComponentNode *node = _spriteNodes[identifier];
    if ([property isEqualToString:@"x"]) {
        return @(node.position.x);
    } else if ([property isEqualToString:@"y"]) {
        return @(node.position.y);
    }
    
    assert(false);
    
    return nil;
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
    
    [self runTimedEvents];
}

- (void)runTimedEvents {
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    [self.timedEvents each:^(ZSTimedEvent *event) {
        if (event.nextTime <= now) {
            event.nextTime += event.interval;
            [self.interpreter triggerEvent:event.eventIdentifier
                    onObjectWithIdentifier:event.objectIdentifier];
        }
    }];
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
