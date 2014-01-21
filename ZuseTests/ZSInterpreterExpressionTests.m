//
//  ZSInterpreterExpressionTests.m
//  Zuse
//
//  Created by Parker Wightman on 1/17/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSInterpreter.h"

@interface ZSInterpreterExpressionTests : XCTestCase

@property (strong, nonatomic) ZSInterpreter *interpreter;

@end

@implementation ZSInterpreterExpressionTests

- (void)setUp
{
    [super setUp];
    _interpreter = [[ZSInterpreter alloc] init];
}

- (NSDictionary *)loadTestFileAtPath:(NSString *)path {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:path
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
}


/************ Numeric Expressions *************/


- (void)testAddition {
    NSDictionary *program = @{ @"+": @[ @1, @2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @3, @"");
}

- (void)testSubtraction {
    NSDictionary *program = @{ @"-": @[ @1, @2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @(-1), @"");
}

- (void)testMultiplication {
    NSDictionary *program = @{ @"*": @[ @7, @2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @14, @"");
}

- (void)testDivision {
    NSDictionary *program = @{ @"/": @[ @10, @2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @5, @"");
}

- (void)testDivisionFloatingPoint {
    NSDictionary *program = @{ @"/": @[ @11, @2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @5.5, @"");
}



/************ Boolean Expressions *************/



- (void)testIsEqualNumber {
    NSDictionary *program = @{ @"==": @[ @2, @2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
}

- (void)testIsEqualNumberFails {
    NSDictionary *program = @{ @"==": @[ @3, @2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
}

- (void)testIsEqualString {
    NSDictionary *program = @{ @"==": @[ @"foo", @"foo" ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
}

- (void)testIsEqualStringFails {
    NSDictionary *program = @{ @"==": @[ @"foo", @"bar" ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
}

- (void)testIsNotEqual {
    NSDictionary *program = @{ @"!=": @[ @"foo", @"bar" ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
}

- (void)testIsNotEqualFails {
    NSDictionary *program = @{ @"!=": @[ @"foo", @"foo" ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
}

- (void)testLessThan {
    NSDictionary *program = @{ @"<": @[ @2.1, @2.2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
    
    program = @{ @"<": @[ @2.3, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
    
    program = @{ @"<": @[ @2.2, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
}

- (void)testGreaterThan {
    NSDictionary *program = @{ @">": @[ @2.1, @2.2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
    
    program = @{ @">": @[ @2.3, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
    
    program = @{ @">": @[ @2.2, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
}

- (void)testLessThanOrEqual {
    NSDictionary *program = @{ @"<=": @[ @2.1, @2.2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
    
    program = @{ @"<=": @[ @2.3, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
    
    program = @{ @"<=": @[ @2.2, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
}

- (void)testGreaterThanOrEqual {
    NSDictionary *program = @{ @">=": @[ @2.1, @2.2 ] };
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @NO, @"");
    
    program = @{ @">=": @[ @2.3, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
    
    program = @{ @">=": @[ @2.2, @2.2 ] };
    result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(result, @YES, @"");
}


/************ Complex Expressions *************/


- (void)testNestedExpression {
    NSDictionary *program = @{
                    @"+": @[
                        @{ @"+": @[ @1, @1 ] },
                        @{ @"+": @[ @2, @2 ] }
                    ]
    };
    
    NSNumber *returnValue = [_interpreter runJSON:program];
    
    XCTAssertEqualObjects(@6, returnValue, @"");
}


@end
