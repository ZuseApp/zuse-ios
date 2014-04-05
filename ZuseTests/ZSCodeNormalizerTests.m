//
//  ZSCodeNormalizerTests.m
//  Zuse
//
//  Created by Parker Wightman on 3/24/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSCodeNormalizer.h"

@interface ZSCodeNormalizerTests : XCTestCase

@end

@implementation ZSCodeNormalizerTests

- (NSDictionary *)loadTestFileAtPath:(NSString *)path {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:path
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
}

- (void)testNormalizedCodeItem
{
    NSDictionary *code = [self loadTestFileAtPath:@"normalize_dsl"];
    
    NSDictionary *actual = [ZSCodeNormalizer normalizedCodeItem:code];
    NSDictionary *expected = [self loadTestFileAtPath:@"normalize_dsl_expected"];
    
    XCTAssertEqualObjects(expected, actual, @"");
}

@end
