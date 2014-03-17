//
//  ZSCodeTransformsTests.m
//  Zuse
//
//  Created by Parker Wightman on 3/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSCodeTransforms.h"

@interface ZSCodeTransformsTests : XCTestCase

@end

@implementation ZSCodeTransformsTests

- (void)testTransformedCodeItemEvery {
    NSDictionary *code = @{
        @"every": @{
            @"seconds": @1,
            @"code": @[
                @{ @"get": @"foo" }
            ]
        }
    };
    
    NSDictionary *actual = ZSCodeTransformEveryBlock(code);
    
    XCTAssertEqualObjects(actual.allKeys.firstObject, @"code", @"");
    
    NSDictionary *event = actual[@"code"][0][@"on_event"];
    XCTAssertNotNil(event, @"");
    XCTAssertNotNil((event[@"name"]), @"");
    XCTAssertEqualObjects((@[]), event[@"parameters"], @"");
    XCTAssertEqualObjects((@[@{ @"get": @"foo" }]), event[@"code"], @"");
    
    NSDictionary *methodCall = actual[@"code"][1][@"call"];
    XCTAssertEqualObjects(@"every_seconds", methodCall[@"method"], @"");
    XCTAssertEqualObjects((@[ @1, event[@"name"] ]), methodCall[@"parameters"], @"");
}

@end
