//
//  ZSZuseDSL.m
//  Zuse
//
//  Created by Parker Wightman on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseDSL.h"
#import "BlocksKit.h"

@implementation ZSZuseDSL

+ (NSDictionary *)onEventJSON {
    return @{
        @"on_event": @{
            @"name": @"#event name",
            @"parameters": @[],
            @"code": @[]
        }
    };
}

+ (NSDictionary *)everyJSON {
    return @{
        @"every": @{
            @"seconds": @1,
            @"code": @[]
        }
    };
}

+ (NSDictionary *)afterJSON {
    return @{
        @"after": @{
            @"seconds": @1,
            @"code": @[]
        }
    };
}

+ (NSDictionary *)inJSON {
    return @{
        @"in": @{
            @"seconds": @1,
            @"code": @[]
        }
    };
}

+ (NSDictionary *)triggerEventJSON {
    return @{
        @"trigger_event": @{
            @"name": @"#event name",
            @"parameters": @{}
        }
    };
}

+ (NSDictionary *)ifJSON {
    return @{
        @"if": @{
            @"test": @"#expression",
            @"true": @[]
        }
    };
}

+ (NSDictionary *)setJSON {
    return @{
        @"set": @[@"#name", @"#value"]
    };
}

+ (NSDictionary *)callFromManifestJSON:(NSDictionary *)entry {
    NSMutableDictionary * call = [@{
        @"call": @{
            @"method": entry[@"name"],
            @"parameters": @[]
        }
    } deepMutableCopy];
    
    call[@"call"][@"parameters"] = [entry[@"parameters"] map:^id(NSDictionary *entryInfo) {
        return [@"#" stringByAppendingString:entryInfo[@"name"]];
    }];
    
    return call;
}

@end
