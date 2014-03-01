//
//  ZSCodePropertyScopeTests.m
//  Zuse
//
//  Created by Parker Wightman on 2/25/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSCodePropertyScope.h"

@interface ZSCodePropertyScopeTests : XCTestCase

@end

@implementation ZSCodePropertyScopeTests

- (NSDictionary *)loadTestFileAtPath:(NSString *)path {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:path
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testFlat
{
    NSArray *code = [self loadTestFileAtPath:@"property_scope_flat"][@"code"];
    
    ZSCodePropertyScope *scope = [ZSCodePropertyScope scopeWithCode:code
                                                  initialProperties:[NSSet set]];
    
    NSSet *propertiesInScope = [scope propertiesAtLine:1];
    XCTAssertEqualObjects(propertiesInScope, ([NSSet setWithObject:@"this"]), @"");
    
    propertiesInScope = [scope propertiesAtLine:3];
    XCTAssertEqualObjects(propertiesInScope, ([NSSet setWithObjects:@"this", @"bar", nil]), @"");
}

// If lineNumber is a 'set' statement, it shouldn't be included in the list
- (void)testFlatOffByOne
{
    NSArray *code = [self loadTestFileAtPath:@"property_scope_flat"][@"code"];
    
    ZSCodePropertyScope *scope = [ZSCodePropertyScope scopeWithCode:code
                                                  initialProperties:[NSSet set]];
    
    NSSet *propertiesInScope = [scope propertiesAtLine:2];
    XCTAssertEqualObjects(propertiesInScope, ([NSSet setWithObject:@"this"]), @"");
}

- (void)testNested {
    NSArray *code = [self loadTestFileAtPath:@"property_scope_nested"][@"code"];
    
    ZSCodePropertyScope *scope = [ZSCodePropertyScope scopeWithCode:code
                                                  initialProperties:[NSSet set]];

    ZSCodePropertyScope *eventScope = [scope nestedScopeForCode:code[1][@"if"][@"true"]
                                                         atLine:1
                                              initialProperties:[NSSet set]];
    
    // would return ["this", "hi"]
    NSSet *eventProperties = [eventScope propertiesAtLine:1];
    
    XCTAssertEqualObjects(eventProperties, ([NSSet setWithArray:@[@"this", @"hi"]]), @"");
}

- (void)testAddStatementFlat {
    NSArray *code = [self loadTestFileAtPath:@"property_scope_flat"][@"code"];
    
    ZSCodePropertyScope *scope = [ZSCodePropertyScope scopeWithCode:code
                                                  initialProperties:[NSSet set]];
    
    [scope addStatement:@{ @"set": @[@"last", @"foo"] } atLine:1];
    
    NSSet *propertiesInScope = [scope propertiesAtLine:2];
    XCTAssertEqualObjects(propertiesInScope, ([NSSet setWithObjects:@"this", @"last", nil]), @"");
    
    propertiesInScope = [scope propertiesAtLine:4];
    XCTAssertEqualObjects(propertiesInScope, ([NSSet setWithObjects:@"this", @"last", @"bar", nil]), @"");
}

- (void)testAddStatementNested {
    NSArray *code = [self loadTestFileAtPath:@"property_scope_nested"][@"code"];
    
    ZSCodePropertyScope *scope = [ZSCodePropertyScope scopeWithCode:code
                                                  initialProperties:[NSSet set]];
    
    ZSCodePropertyScope *eventScope = [scope nestedScopeForCode:code[1][@"if"][@"true"]
                                                         atLine:1
                                              initialProperties:[NSSet set]];
    
    [scope addStatement:@{ @"set": @[@"last", @"foo"] } atLine:1];
    
    NSSet *eventProperties = [eventScope propertiesAtLine:1];
    
    XCTAssertEqualObjects(eventProperties, ([NSSet setWithObjects:@"this", @"last", @"hi", nil]), @"");
}

@end
