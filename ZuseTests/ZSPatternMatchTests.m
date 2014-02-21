//
//  ZSPatternMatchTests.m
//  Zuse
//
//  Created by Parker Wightman on 2/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSPatternMatch.h"

@interface ZSPatternMatchTests : XCTestCase

@end

@implementation ZSPatternMatchTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testNormalizedValuesSet
{
    NSArray *result = [ZSPatternMatch normalizedValuesForCodeSuite:@[ @{ @"set": @[@"#this", @1] } ]];
    XCTAssertEqualObjects(@[], result, @"");
    
    result = [ZSPatternMatch normalizedValuesForCodeSuite:@[ @{ @"set": @[@"#this", @"#that"] } ]];
    XCTAssertEqualObjects(@[], result, @"");
    
    result = [ZSPatternMatch normalizedValuesForCodeSuite:@[ @{ @"set": @[@"this", @"that"] } ]];
    XCTAssertEqualObjects((@[ @{ @"set": @[@"this", @"that"] } ]), result, @"");
    
}

- (void)testNormalizedValuesGet {
    NSArray *result = [ZSPatternMatch normalizedValuesForCodeSuite:@[ @{ @"get": @"#this" } ]];
    XCTAssertEqualObjects(@[], result, @"");
    
    result = [ZSPatternMatch normalizedValuesForCodeSuite:@[ @{ @"get": @"foo" } ]];
    XCTAssertEqualObjects((@[ @{ @"get": @"foo" } ]), result, @"");
}

@end
