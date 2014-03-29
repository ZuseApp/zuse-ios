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
@property (assign, nonatomic) BOOL shouldDelegate;
@property (assign, nonatomic) BOOL didRunShouldDelegateProperties;
@property (assign, nonatomic) BOOL didRunValueForProperty;
@property (assign, nonatomic) id   delegationValue;

@end

@implementation ZSInterpreterDelegateTests

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

- (void)testShouldDelegateProperty {
    self.shouldDelegate = YES;
    self.delegationValue = @10;
    
    ZSInterpreter *interpreter = [ZSInterpreter interpreter];
    
    interpreter.delegate = self;
    
    NSNumber *result = [interpreter runJSON:@{ @"get": @"foo" }];
    
    XCTAssertEqualObjects(self.delegationValue, result, @"");
    XCTAssertTrue(self.didRunShouldDelegateProperties, @"");
    XCTAssertTrue(self.didRunValueForProperty, @"");
}

- (void) interpreter:(ZSInterpreter *)interpreter
objectWithIdentifier:(NSString *)identifier
 didUpdateProperties:(NSDictionary *)properties {
    _didRunUpdateProperties = YES;
    XCTAssertEqualObjects(properties, (@{ @"x": @10 }), @"");
}

- (BOOL) interpreter:(ZSInterpreter *)interpreter shouldDelegateProperty:(NSString *)property objectIdentifier:(NSString *)identifier {
    XCTAssertEqualObjects(@"foo", property, @"");
    XCTAssertNotNil(identifier, @"");
    self.didRunShouldDelegateProperties = YES;
    return self.shouldDelegate;
}

- (id)interpreter:(ZSInterpreter *)interpreter valueForProperty:(NSString *)property objectIdentifier:(NSString *)identifier {
    XCTAssertEqualObjects(@"foo", property, @"");
    XCTAssertNotNil(identifier, @"");
    self.didRunValueForProperty = YES;
    return self.delegationValue;
}

@end
