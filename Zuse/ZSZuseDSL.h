//
//  ZSZuseDSL.h
//  Zuse
//
//  Created by Parker Wightman on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSZuseDSL : NSObject

+ (NSDictionary *)onEventJSON;
+ (NSDictionary *)triggerEventJSON;
+ (NSDictionary *)ifJSON;
+ (NSDictionary *)setJSON;

+ (NSDictionary *)callFromManifestJSON:(NSDictionary *)entry;

@end
