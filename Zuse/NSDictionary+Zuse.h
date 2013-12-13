//
//  NSDictionary+Zuse.h
//  Zuse
//
//  Created by Parker Wightman on 12/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Zuse)

- (NSDictionary *)deepCopy;
- (NSMutableDictionary *)deepMutableCopy;

@end
