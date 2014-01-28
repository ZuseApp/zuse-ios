//
//  ZSCompilerTests.m
//  Zuse
//
//  Created by Parker Wightman on 11/18/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSInterpreter.h"
#import "ZSCompiler.h"

@interface ZSCompilerTests : XCTestCase

@end

@implementation ZSCompilerTests

- (NSDictionary *)loadTestFileAtPath:(NSString *)path {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:path
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
}

- (void)testCompileTraits {
    NSDictionary *projectWithTraits = [self loadTestFileAtPath:@"project_traits"];
    
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:projectWithTraits];
    
    NSDictionary *compiledJSON = [compiler compiledJSON];
    
    ZSInterpreter *interpreter = [ZSInterpreter interpreter];
    
    __block BOOL didRunInObject = NO;
    
    [interpreter loadMethod:@{
        @"method": @"in_object",
        @"block": ^id(NSString *identifier, NSArray *params) {
            didRunInObject = YES;
            XCTAssertEqual(params.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(params[0], [NSNull null], @"");
            XCTAssertEqualObjects(params[1], @"baz", @"");
            return nil;
        }
    }];
    
    
    __block BOOL didRunInTrait = NO;
    
    [interpreter loadMethod:@{
        @"method": @"in_trait",
        @"block": ^id(NSString *identifier, NSArray *params) {
            didRunInTrait = YES;
            XCTAssertEqual(params.count, [@3 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(params[0], @"bar", @"");
            XCTAssertEqualObjects(params[1], @"baz", @"");
            XCTAssertEqualObjects(params[2], @"test", @"");
            return nil;
        }
    }];
    
    
    [interpreter runJSON:compiledJSON];
    
    XCTAssert(didRunInObject, @"");
    XCTAssert(didRunInTrait, @"");
}

- (void)testProjectObjectTransform {
    NSDictionary *original = [self loadTestFileAtPath:@"object_transform"];
    NSDictionary *expected = [self loadTestFileAtPath:@"object_transform_result"];
    
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:original];
    
    XCTAssertEqualObjects(expected, compiler.compiledJSON, @"");
}
@end
