//
//  ZSInterpreterDelegateTests.m
//  Zuse
//
//  Created by Parker Wightman on 11/18/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSInterpreter.h"

@interface ZSInterpreterDelegateTests : XCTestCase <ZSInterpreterDelegate>

@property (assign, nonatomic) BOOL didRunUpdateProperties;

@end

@implementation ZSInterpreterDelegateTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (NSDictionary *)loadTestFileAtPath:(NSString *)path {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:path
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
}

- (void)testDidUpdateProperties {
    _didRunUpdateProperties = NO;
    
    ZSInterpreter *interpreter = [ZSInterpreter interpreter];
    
    interpreter.delegate = self;
    
    NSDictionary *JSON = [self loadTestFileAtPath:@"property_update"];
    
    [interpreter runJSON:JSON];
    
    XCTAssert(_didRunUpdateProperties, @"");
}

- (void) interpreter:(ZSInterpreter *)interpreter
objectWithIdentifier:(NSString *)identifier
 didUpdateProperties:(NSDictionary *)properties {
    _didRunUpdateProperties = YES;
    XCTAssertEqualObjects(properties, (@{ @"x": @10 }), @"");
}

@end
