//
//  ZSAuthTokenPersistence.h
//  Zuse
//
//  Created by Sarah Hong on 3/10/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSAuthTokenPersistence : NSObject

+ (void)writeTokenInfo:(NSString *)token;
+ (NSString *)getTokenInfo;
+ (void)deleteToken;

@end