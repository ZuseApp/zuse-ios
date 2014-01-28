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
    
    [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"parameters": @[ @"Hello World!" ]
        }
    };
    
    [_interpreter runJSON:program];
    
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
    
    [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print"
        }
    };
    
    [_interpreter runJSON:program];
    
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
    
    [_interpreter loadMethod:method];
    
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
    
    [_interpreter runJSON:program];
    
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
    
    [_interpreter runJSON:program];
    
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
    
    [_interpreter loadMethod:method];
    
    [_interpreter runJSON: @{
        @"on_event": @{
            @"name": @"start",
            @"code": @[
                @{ @"call": @{ @"method": @"test", @"parameters": @[] } }
            ]
        }
    }];
    
    [_interpreter triggerEvent:@"start"];
    
    XCTAssert(didRun, @"");
}

- (void)testAsyncMethod {
    NSDictionary *method = @{
        @"method":  @"print",
        @"block": ^(NSString *identifier, NSArray *args, void(^finishedBlock)(id)) {
            finishedBlock(@YES);
            return [NSNull null];
        }
    };
    
   [_interpreter loadMethod:method];
    
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
    NSNumber *result = [_interpreter runJSON:program];
    XCTAssertEqualObjects(@YES, result, @"");
}

- (void)testScope {
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
    
    [_interpreter loadMethod:method];
    
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
    
    [_interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"scope"];
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:json];
    
    [_interpreter runJSON:compiler.compiledJSON];
    
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
    
    [_interpreter loadMethod:method];
    
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

    [_interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"scope_set_object_var"];
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:json];
    
    [_interpreter runJSON:compiler.compiledJSON];
    
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
    
    [_interpreter loadMethod:method];
    
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

    [_interpreter loadMethod:method];
    
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

    [_interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"events_scope"];
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:json];
    
    [_interpreter runJSON:compiler.compiledJSON];
    
    [_interpreter triggerEvent:@"my_event" onObjectWithIdentifier:@"my_object" parameters:@{
        @"x": @10,
        @"y": @11
    }];
    
    XCTAssert(checkOneDidRun, @"");
    XCTAssert(checkTwoDidRun, @"");
    XCTAssert(checkParametersDidRun, @"");
}

- (void)testObjects {
    [_interpreter runJSON:@{
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
    
    XCTAssertEqualObjects((expectedObjects[@"foo"]), ([_interpreter objects][@"foo"]), @"");
}

@end
