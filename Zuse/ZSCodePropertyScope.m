//
//  ZSCodePropertyScope.m
//  Zuse
//
//  Created by Parker Wightman on 2/25/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSCodePropertyScope.h"
#import "BlocksKit.h"

@interface ZSCodePropertyScope ()

@property (strong, nonatomic) NSMutableArray *codeLines;
@property (strong, nonatomic) NSSet *initialProperties;
@property (copy, nonatomic)   NSSet *(^propertiesInParent)();
@property (assign, nonatomic) NSInteger uniqueIDCounter;

@end

@implementation ZSCodePropertyScope

+ (instancetype)scopeWithCode:(NSArray *)codeLines initialProperties:(NSSet *)properties {
    return [[self alloc] initWithCode:codeLines
                    initialProperties:properties];
}

- (instancetype)initWithCode:(NSArray *)codeLines
           initialProperties:(NSSet *)properties {
    self = [super init];
    
    if (self) {
        self.initialProperties = [properties copy];
        self.uniqueIDCounter = 0;
        
        self.codeLines = [[codeLines map:^id(NSDictionary *codeLine) {
            return [self codeLineWithUniqueID:codeLine];
        }] deepMutableCopy];
    }
    
    return self;
}

- (NSArray *)codeLineWithUniqueID:(NSDictionary *)codeLine
{
    return @[ @(self.uniqueIDCounter++), codeLine ];
}

- (NSInteger)uniqueIDForLine:(NSInteger)lineNumber
{
    return [self.codeLines[lineNumber][0] integerValue];
}

- (instancetype)nestedScopeForCode:(NSArray *)codeLines
                            atLine:(NSInteger)line
                 initialProperties:(NSSet *)initialProperties {
    ZSCodePropertyScope *newScope = [self.class scopeWithCode:codeLines
                                            initialProperties:initialProperties];
    
    NSInteger uniqueID = [self uniqueIDForLine:line];
    
    newScope.propertiesInParent = ^NSSet *() {
        return [self.initialProperties setByAddingObjectsFromSet:[self propertiesAtUniqueID:uniqueID]];
    };
    
    return newScope;
}

- (NSSet *)propertiesAtUniqueID:(NSInteger)uniqueID {
    __block NSInteger realIndex = -1;
    
    [self.codeLines enumerateObjectsUsingBlock:^(NSArray *codeLine, NSUInteger idx, BOOL *stop) {
        if ([codeLine[0] integerValue] == uniqueID) {
            realIndex = idx;
            (*stop) = YES;
        }
    }];
    
    assert(realIndex != -1);
    
    return [self propertiesAtLine:realIndex];
}

- (void)addStatement:(NSDictionary *)statement atLine:(NSInteger)lineNumber {
    [self.codeLines insertObject:[self codeLineWithUniqueID:statement] atIndex:lineNumber];
}

- (NSSet *)propertiesAtLine:(NSInteger)lineNumber {
    NSMutableSet *properties = [self.initialProperties mutableCopy];
    
    if (self.propertiesInParent) {
        properties = [[properties setByAddingObjectsFromSet:self.propertiesInParent()] mutableCopy];
    }
    
    [self.codeLines enumerateObjectsUsingBlock:^(NSArray *codeLine, NSUInteger idx, BOOL *stop) {
        if (idx == lineNumber) {
            (*stop) = YES;
            return;
        }
        
        NSDictionary *statement = codeLine[1];
        if ([statement.allKeys.firstObject isEqualToString:@"set"]) {
            [properties addObject:statement[@"set"][0]];
        }
    }];
    
    return properties;
}

@end
