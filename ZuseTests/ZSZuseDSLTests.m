//
//  ZSZuseDSLTests.m
//  Zuse
//
//  Created by Parker Wightman on 3/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSZuseDSL.h"

@interface ZSZuseDSLTests : XCTestCase

@end

@implementation ZSZuseDSLTests

- (void)testCallFromManifestJSON
{
    NSDictionary *manifest = @{
        @"name": @"move",
        @"return_type": @"none",
        @"parameters": @[
            @{
                @"name": @"direction",
                @"types": @[@"numeric"]
            },
            @{
                @"name": @"speed",
                @"types": @[@"numeric"]
            }
        ]
    };
      
    NSDictionary *actual = [ZSZuseDSL callFromManifestJSON:manifest];
    
    NSDictionary *expected = @{
        @"call": @{
            @"method": @"move",
            @"parameters": @[@"#direction", @"#speed"]
        }
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

@end
