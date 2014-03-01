//
//  ZSCodePropertyScope.h
//  Zuse
//
//  Created by Parker Wightman on 2/25/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSCodePropertyScope : NSObject

- (instancetype)initWithCode:(NSArray *)codeLines initialProperties:(NSSet *)properties;

+ (instancetype)scopeWithCode:(NSArray *)codeLines
            initialProperties:(NSSet *)properties;

- (NSSet *)propertiesAtLine:(NSInteger)lineNumber;

- (void)addStatement:(NSDictionary *)statement
              atLine:(NSInteger)lineNumber;

- (instancetype)nestedScopeForCode:(NSArray *)codeLines
                            atLine:(NSInteger)line
                 initialProperties:(NSSet *)initialProperties;

@end
