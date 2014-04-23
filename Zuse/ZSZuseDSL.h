//
//  ZSZuseDSL.h
//  Zuse
//
//  Created by Parker Wightman on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSZuseDSL : NSObject

+ (NSDictionary *)propertiesJSON;
+ (NSDictionary *)onEventJSON;
+ (NSDictionary *)triggerEventJSON;
+ (NSDictionary *)ifJSON;
+ (NSDictionary *)setJSON;
+ (NSDictionary *)everyJSON;
+ (NSDictionary *)afterJSON;
+ (NSDictionary *)inJSON;

+ (NSDictionary *)callFromManifestJSON:(NSDictionary *)entry;

@end
