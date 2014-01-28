//
//  ZSCompiler.h
//  Zuse
//
//  Created by Parker Wightman on 11/16/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSCompiler : NSObject

+ (instancetype) compilerWithProjectJSON:(NSDictionary *)projectJSON;
- (NSDictionary *)compiledJSON;

@end
