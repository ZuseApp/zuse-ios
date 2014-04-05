//
//  NSString+coercedString.h
//  Zuse
//
//  Created by Parker Wightman on 1/28/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Zuse)

- (NSString *)coercedString;
- (NSNumber *)coercedNumber;
- (NSNumber *)coercedBool;

@end
