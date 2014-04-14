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
#import "ZSProjectJSONKeys.h"


@interface ZSRendererScene() <ZSInterpreterDelegate>

@property (assign, nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (strong, nonatomic) NSMutableDictionary *spriteNodes;
@property (strong, nonatomic) NSMutableDictionary *movingSprites;
@property (strong, nonatomic) ZSInterpreter *interpreter;
@property (strong, nonatomic) NSDictionary *projectJSON;
@property (strong, nonatomic) NSDictionary *categoryBitMasks;
@property (strong, nonatomic) NSDictionary *collisionBitMasks;
@property (strong, nonatomic) NSMutableArray *timedEvents;
@property (strong, nonatomic) NSDictionary *compiledComponents;

@end

NSString * const kZSSpriteName = @"sprite";

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
        self.spriteNodes   = [NSMutableDictionary dictionary];
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
    node.group      = spriteJSON[@"collision_group"];
    node.name = kZSSpriteName;
    node.position = position;
    
    SKNode *childNode = [self childNodeForObjectJSON:spriteJSON size:size];
    [node addChild:childNode];
    
    if(!_spriteNodes[spriteJSON[@"id"]]) {
        _spriteNodes[spriteJSON[@"id"]] = node;
    }
    
    node.physicsBody = [self physicsBodyForType:spriteJSON[@"physics_body"] size:size];
    
    if (node.physicsBody) {
        node.physicsBody.categoryBitMask    = [self.categoryBitMasks[spriteJSON[@"collision_group"]] intValue];
        node.physicsBody.collisionBitMask = 0;
        node.physicsBody.contactTestBitMask = [self.collisionBitMasks[spriteJSON[@"collision_group"]] intValue];
        
        node.physicsBody.dynamic = NO;
        node.physicsBody.mass    = 0.02;
        node.physicsBody.affectedByGravity = NO;
    }
    
    ZSSpriteTouchComponent *touchComponent = [ZSSpriteTouchComponent new];
    touchComponent.spriteId = spriteJSON[@"id"];
    
    touchComponent.touchesBegan = ^(UITouch *touch) {
        if (node.physicsBody) {
            node.physicsBody.dynamic = YES;
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
        CGPoint point = [touch locationInNode:self];
        
        [_interpreter triggerEvent:@"touch_ended"
            onObjectWithIdentifier:spriteJSON[@"id"]
                        parameters:@{ @"touch_x": @(point.x), @"touch_y": @(point.y) }];
        if (node.physicsBody) {
            node.physicsBody.dynamic = NO;
        }
    };
    
    [node addComponent:touchComponent];
    [self addChild:node];
    

}

- (void) setupInterpreterWithProjectJSON:(NSDictionary *)projectJSON {
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:projectJSON options:ZSCompilerOptionWrapInStartEvent];
    [self loadMethodsIntoInterpreter:_interpreter];

    self.compiledComponents = compiler.compiledComponents;
    [_interpreter runJSON:self.compiledComponents[@"objects"]];
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
        labelNode.fontSize = 17;
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
            onObjectWithIdentifier:nodeA.identifier
                        parameters:@{ @"other_group": nodeB.group }];
        [_interpreter triggerEvent:@"collision"
            onObjectWithIdentifier:nodeB.identifier
                        parameters:@{ @"other_group": nodeA.group }];
    } else {
        ZSComponentNode *node = (ZSComponentNode *)(contact.bodyA.categoryBitMask != GFPhysicsCategoryWorld ? contact.bodyA.node : contact.bodyB.node);
        [_interpreter triggerEvent:@"collision"
            onObjectWithIdentifier:node.identifier
                        parameters:@{ @"other_group": @"world" }];
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
        @"method": @"explosion",
        @"block": ^id(NSString *identifier, NSArray *args) {
            CGFloat x = [args[0] floatValue];
            CGFloat y = [args[1] floatValue];
            [self addParticle:identifier position:CGPointMake(x, y) duration:0.15f particleType:@"Explosion"];
            return nil;
        }
    }];
    
    [interpreter loadMethod:@{
        @"method": @"every_seconds",
        @"block": ^id(NSString *identifier, NSArray *args) {
            CGFloat seconds = [args[0] floatValue];
            NSString *eventIdentifier = args[1];
            [self addTimerWithDuration:seconds
                       runsImmediately:YES
                               repeats:YES
                      objectIdentifier:identifier
                       eventIdentifier:eventIdentifier];
            NSLog(@"%@", args);
            return nil;
        }
    }];

    [interpreter loadMethod:@{
        @"method": @"after_seconds",
        @"block": ^id(NSString *identifier, NSArray *args) {
            CGFloat seconds = [args[0] floatValue];
            NSString *eventIdentifier = args[1];
            [self addTimerWithDuration:seconds
                       runsImmediately:NO
                               repeats:YES
                      objectIdentifier:identifier
                       eventIdentifier:eventIdentifier];
            NSLog(@"%@", args);
            return nil;
        }
    }];

    [interpreter loadMethod:@{
        @"method": @"in_seconds",
        @"block": ^id(NSString *identifier, NSArray *args) {
            CGFloat seconds = [args[0] floatValue];
            NSString *eventIdentifier = args[1];
            [self addTimerWithDuration:seconds
                       runsImmediately:NO
                               repeats:NO
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
            return @((arc4random() % (high + 1)) + low);
        }
    }];
    
    [interpreter loadMethod:@{
        @"method": @"generate",
        @"block": ^id(NSString *identifier, NSArray *args) {
            NSString *generatorIdentifier = args[0];
            NSNumber *x = args[1];
            NSNumber *y = args[2];
        
            // TODO: Complete and utter hack to stop the app from crashing
            // until we can figure out why x is NaN sometimes.
            if (isnan(x.doubleValue)) return nil;
        
            NSMutableDictionary *object = self.compiledComponents[@"generators"][generatorIdentifier];

            if (!object) return nil;

            NSLog(@"%@", generatorIdentifier);
        
            object[@"object"][@"id"] = [NSUUID.UUID UUIDString];
            [object[@"object"][@"properties"] addEntriesFromDictionary:@{ @"x": x, @"y": y }];
        
            [self.interpreter runJSON:object];

            NSMutableDictionary *DSLSprite = [(NSDictionary *)[(NSArray *)self.projectJSON[@"generators"] match:^BOOL(NSDictionary *generator) {
                return [generator[@"name"] isEqualToString:generatorIdentifier];
            }] deepMutableCopy];

            DSLSprite[@"id"] = object[@"object"][@"id"];
            [DSLSprite[@"properties"] addEntriesFromDictionary:@{ @"x": x, @"y": y }];
        
            [self addSpriteWithJSON:DSLSprite];
        
            [self.interpreter triggerEvent:@"start" onObjectWithIdentifier:object[@"object"][@"id"]];
        
            return nil;
        }
    }];
}

- (void)addTimerWithDuration:(CGFloat)seconds
             runsImmediately:(BOOL)runsImmediately
                     repeats:(BOOL)repeats
            objectIdentifier:(NSString *)objectIdentifier
             eventIdentifier:(NSString *)eventIdentifier {
    ZSTimedEvent *event = [[ZSTimedEvent alloc] init];
    event.interval = seconds;
    event.repeats = repeats;
    CGFloat addTime = (runsImmediately ? 0 : seconds);
    event.nextTime = [[NSDate date] timeIntervalSinceReferenceDate] + addTime;
    event.eventIdentifier = eventIdentifier;
    event.objectIdentifier = objectIdentifier;
    
    [self.timedEvents addObject:event];
}

- (void)removeSpriteWithIdentifier:(NSString *)identifier {
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
    NSString *burstPath = [[NSBundle mainBundle] pathForResource:particleType ofType:@"sks"];
    
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
        node.position = CGPointMake([properties[@"x"] floatValue], node.position.y);
    }
    else if (properties[@"y"]) {
        node.position = CGPointMake(node.position.x, [properties[@"y"] floatValue]);
    }
    else if (properties[@"hidden"]) {
        node.hidden = [properties[@"hidden"] boolValue];
    }
    else if (properties[@"angle"]) {
        node.zRotation = ([properties[@"angle"] floatValue] / 180.0 * M_PI);
    }
    else if (properties[@"text"]) {
        SKLabelNode *textNode = [node.children match:^BOOL(id obj) {
            return [obj isKindOfClass:SKLabelNode.class];
        }];
        if (textNode) {
            textNode.text = [properties[@"text"] coercedString];
        }
    }

    if (properties[@"width"]) {
        SKSpriteNode *spriteNode = node.children[0];
        CGSize size = spriteNode.size;
        size.width = [properties[@"width"] floatValue];
        spriteNode.size = size;
    }
    else if (properties[@"height"]) {
        SKSpriteNode *spriteNode = node.children[0];
        CGSize size = spriteNode.size;
        size.height = [properties[@"height"] floatValue];
        spriteNode.size = size;
    }
}

- (BOOL)interpreter:(ZSInterpreter *)interpreter shouldDelegateProperty:(NSString *)property objectIdentifier:(NSString *)identifier {
    return [@[@"x", @"y"] indexOfObject:property] != NSNotFound;
}

- (id)interpreter:(ZSInterpreter *)interpreter valueForProperty:(NSString *)property objectIdentifier:(NSString *)identifier {
    ZSComponentNode *node = _spriteNodes[identifier];
    if (node.position.x != node.position.x) {
        NSLog(@"position: %@", NSStringFromCGPoint(node.position));
    }
    if ([property isEqualToString:@"x"]) {
        return @(node.position.x);
    } else if ([property isEqualToString:@"y"]) {
        return @(node.position.y);
    } else if ([property isEqualToString:@"hidden"]) {
        return @(node.hidden);
    } else if ([property isEqualToString:@"angle"]) {
        return @(node.zRotation);
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
    NSArray *events = self.timedEvents.copy;
    [self.timedEvents removeAllObjects];
    NSArray *newEvents = [events select:^BOOL(ZSTimedEvent *event) {
        if (event.nextTime <= now) {
            event.nextTime += event.interval;
            [self.interpreter triggerEvent:event.eventIdentifier
                    onObjectWithIdentifier:event.objectIdentifier];
            return event.repeats;
        }

        return YES;
    }];
    [self.timedEvents addObjectsFromArray:newEvents];
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
