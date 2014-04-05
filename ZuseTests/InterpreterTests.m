//
//  InterpreterTests.m
//  InterpreterTests
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSInterpreter.h"
#import "ZSCompiler.h"

@interface InterpreterTests : XCTestCase

@property (strong, nonatomic) ZSCompiler *compiler;
@property (strong, nonatomic) ZSInterpreter *interpreter;

@end

@implementation InterpreterTests

- (void)setUp
{
    [super setUp];
    self.interpreter = [[ZSInterpreter alloc] init];
}

- (NSDictionary *)loadTestFileAtPath:(NSString *)path {
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource:path
                                                                      ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:0
                                             error:nil];
}

- (void)testPrint
{
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"method":  @"print",
        @"block": ^(NSString *identifier, NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@"Hello World!", args[0], @"");
            return [NSNull null];
        }
    };
    
    [self.interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"parameters": @[ @"Hello World!" ]
        }
    };
    
    [self.interpreter runJSON:program];
    
    XCTAssertEqual(YES, didRun, @"");
}

- (void)testCallNoArgs {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"method":  @"print",
        @"block": ^id(NSString *identifier, NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@[], args, @"");
            return [NSNull null];
        }
    };
    
    [self.interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print"
        }
    };
    
    [self.interpreter runJSON:program];
    
    XCTAssertEqual(YES, didRun, @"");

}

- (void)testIf
{
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"method":  @"print",
        @"block": ^id(NSString *identifier, NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@"Hello World!", args[0], @"");
            return [NSNull null];
        }
    };
    
    [self.interpreter loadMethod:method];
    
    NSNumber *value = @NO;
    NSDictionary *program = @{
        @"if": @{
            @"test": value,
            @"true": @[
                @{
                    @"call": @{
                        @"method": @"print",
                        @"parameters": @[ @"Hello World!" ]
                    }
                }
            ],
            @"false": @[ ]
        }
    };
    
    [self.interpreter runJSON:program];
    
    XCTAssertFalse(didRun, @"");
    
    value = @YES;
    
    program = @{
        @"if": @{
            @"test": value,
            @"true": @[
                @{
                    @"call": @{
                        @"method": @"print",
                        @"parameters": @[ @"Hello World!" ]
                    }
                }
            ]
        }
    };
    
    [self.interpreter runJSON:program];
    
    XCTAssert(didRun, @"");
}

- (void)testEvents {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"method":  @"test",
        @"block": ^id(NSString *identifier, NSArray *args) {
            didRun = YES;
            return [NSNull null];
        }
    };
    
    [self.interpreter loadMethod:method];
    
    [self.interpreter runJSON: @{
        @"on_event": @{
            @"name": @"start",
            @"code": @[
                @{ @"call": @{ @"method": @"test", @"parameters": @[] } }
            ]
        }
    }];
    
    [self.interpreter triggerEvent:@"start"];
    
    XCTAssert(didRun, @"");
}

- (void)testMutipleOfSameEvent {
    __block BOOL didRun = NO;
    __block BOOL didRun2 = NO;
    
    NSDictionary *method = @{
        @"method":  @"test",
        @"block": ^id(NSString *identifier, NSArray *args) {
            didRun = YES;
            return [NSNull null];
        }
    };
    
    NSDictionary *method2 = @{
        @"method":  @"test2",
        @"block": ^id(NSString *identifier, NSArray *args) {
            didRun2 = YES;
            return [NSNull null];
        }
    };
    
    [self.interpreter loadMethod:method];
    [self.interpreter loadMethod:method2];
    
    [self.interpreter runJSON:@{
        @"suite": @[
            @{
                @"on_event": @{
                    @"name": @"start",
                    @"code": @[
                        @{ @"call": @{ @"method": @"test", @"parameters": @[] } }
                    ]
                }
            },
            @{
                @"on_event": @{
                    @"name": @"start",
                    @"code": @[
                        @{ @"call": @{ @"method": @"test2", @"parameters": @[] } }
                    ]
                }
            }
        ]
    }];
    
    [self.interpreter triggerEvent:@"start"];
    
    XCTAssert(didRun, @"");
    XCTAssert(didRun2, @"");
}

- (void)testAsyncMethod {
    NSDictionary *method = @{
        @"method":  @"print",
        @"block": ^(NSString *identifier, NSArray *args, void(^finishedBlock)(id)) {
            finishedBlock(@YES);
            return [NSNull null];
        }
    };
    
   [self.interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"async": @YES
        }
    };
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(backgroundAsync:) object:program];
    
    [thread start];
    
    while (!thread.isFinished) { sleep(1); }
}


- (void)backgroundAsync:(NSDictionary *)program {
    NSNumber *result = [self.interpreter runJSON:program];
    XCTAssertEqualObjects(@YES, result, @"");
}

- (void)testSuite {
    __block BOOL didRun1 = NO;
    NSDictionary *method = @{
        @"method":  @"check1",
        @"block": ^id(NSString *identifier, NSArray *args) {
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqualObjects(args[1], @"bar", @"");
            didRun1 = YES;
            return @YES;
        }
    };
    
    [self.interpreter loadMethod:method];
    
    __block BOOL didRun2 = NO;
    method = @{
        @"method":  @"check2",
        @"block": ^id(NSString *identifier, NSArray *args) {
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqual(args[1], [NSNull null], @"");
            didRun2 = YES;
            return @YES;
        }
    };
    
    [self.interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"suite"];
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:json];
    
    [self.interpreter runJSON:compiler.compiledJSON];
    
    XCTAssert(didRun1, @"");
    XCTAssert(didRun2, @"");
}

- (void)testScopeSetObjectScopeProperty {
    __block BOOL didRunCheckOne = NO;
    
    NSDictionary *method = @{
        @"method":  @"check1",
        @"block": ^id(NSString *identifier, NSArray *args) {
            didRunCheckOne = YES;
            XCTAssertEqual(args.count, [@1 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"bar", @"");
            return @YES;
        }
    };
    
    [self.interpreter loadMethod:method];
    
    __block BOOL didRunCheckTwo = NO;
    method = @{
        @"method":  @"check2",
        @"block": ^id(NSString *identifier, NSArray *args) {
            didRunCheckTwo = YES;
            XCTAssertEqual(args.count, [@1 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"bar", @"");
            return @YES;
        }
    };

    [self.interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"scope_set_object_var"];
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:json];
    
    [self.interpreter runJSON:compiler.compiledJSON];
    
    XCTAssert(didRunCheckOne, @"");
    XCTAssert(didRunCheckTwo, @"");
}

- (void)testEventScope {
    __block BOOL checkOneDidRun = NO;
    NSDictionary *method = @{
        @"method":  @"check1",
        @"block": ^id(NSString *identifier, NSArray *args) {
            checkOneDidRun = YES;
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqualObjects(args[1], @"bar", @"");
            return @YES;
        }
    };
    
    [self.interpreter loadMethod:method];
    
    __block BOOL checkTwoDidRun = NO;
    method = @{
        @"method":  @"check2",
        @"block": ^id(NSString *identifier, NSArray *args) {
            checkTwoDidRun = YES;
            XCTAssertEqual(args.count, [@4 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqual(args[1], [NSNull null], @"");
            XCTAssertEqual(args[2], [NSNull null], @"");
            XCTAssertEqual(args[3], [NSNull null], @"");
            return @YES;
        }
    };

    [self.interpreter loadMethod:method];
    
    __block BOOL checkParametersDidRun = NO;
    method = @{
        @"method":  @"checkParameters",
        @"block": ^id(NSString *identifier, NSArray *args) {
            checkParametersDidRun = YES;
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @10, @"");
            XCTAssertEqual(args[1], @11, @"");
            return @YES;
        }
    };

    [self.interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"events_scope"];
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:json];
    
    [self.interpreter runJSON:compiler.compiledJSON];
    
    [self.interpreter triggerEvent:@"my_event" onObjectWithIdentifier:@"my_object" parameters:@{
        @"x": @10,
        @"y": @11
    }];
    
    XCTAssert(checkOneDidRun, @"");
    XCTAssert(checkTwoDidRun, @"");
    XCTAssert(checkParametersDidRun, @"");
}

- (void)testObjects {
    [self.interpreter runJSON:@{
        @"object": @{
            @"id": @"foo",
            @"properties": @{
                @"x": @10,
                @"y": @11
            },
            @"code": @[ ]
        }
    }];
    
    NSDictionary *expectedObjects = @{
        @"foo": @{
            @"x": @10,
            @"y": @11
        }
    };
    
    XCTAssertEqualObjects((expectedObjects[@"foo"]), ([self.interpreter allObjects][@"foo"]), @"");
}

@end
