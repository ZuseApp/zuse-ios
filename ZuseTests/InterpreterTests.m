//
//  InterpreterTests.m
//  InterpreterTests
//
//  Created by Parker Wightman on 9/16/13.
//  Copyright (c) 2013 Alora Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "INInterpreter.h"

@interface InterpreterTests : XCTestCase

@property (strong, nonatomic) INInterpreter *interpreter;

@end

@implementation InterpreterTests

- (void)setUp
{
    [super setUp];
    _interpreter = [[INInterpreter alloc] init];
}

- (void)testPrint
{
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"name":  @"print",
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@"Hello World!", args[0], @"");
        }
    };
    
    [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"args": @[ @"Hello World!" ]
        }
    };
    
    [_interpreter runJSON:program];
    
    XCTAssertEqual(YES, didRun, @"");
}

- (void)testCallNoArgs {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"name":  @"print",
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@[], args, @"");
        }
    };
    
    [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
        }
    };
    
    [_interpreter runJSON:program];
    
    XCTAssertEqual(YES, didRun, @"");

}

- (void)testIf
{
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"name":  @"print",
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@"Hello World!", args[0], @"");
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
                        @"args": @[ @"Hello World!" ]
                    }
                }
            ],
            @"false": @[ ]
        }
    };
    
    [_interpreter runJSON:program];
    
    XCTAssert(!didRun, @"");
    
    value = @YES;
    
    program = @{
        @"if": @{
            @"test": value,
            @"true": @[
                @{
                    @"call": @{
                        @"method": @"print",
                        @"args": @[ @"Hello World!" ]
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
        @"name":  @"test",
        @"block": ^(NSArray *args) {
            didRun = YES;
        }
    };
    
    [_interpreter loadMethod:method];
    
    [_interpreter registerEvent:@"some_object.tapped" handler:@{
        @"suite": @[
            @{ @"call": @{ @"method": @"test", @"args": @[] } }
        ]
    }];
    
    [_interpreter triggerEvent:@"some_object.tapped"];
    
    XCTAssert(didRun, @"");
}

- (void)testSimpleExpression {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"name":  @"print",
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@3, args[0], @"");
        }
    };
    
    [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"args": @[ @{ @"+": @[ @1, @2 ] } ]
        }
    };
    
    [_interpreter runJSON:program];
    
    XCTAssertEqual(YES, didRun, @"");
}

- (void)testNestedExpression {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"name":  @"print",
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@6, args[0], @"");
        }
    };
    
   [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"args": @[
                @{
                    @"+": @[
                        @{ @"+": @[ @1, @1 ] },
                        @{ @"+": @[ @2, @2 ] }
                    ]
                }
            ]
        }
    };
    
    [_interpreter runJSON:program];
    
}

- (void)testAsyncMethod {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"name":  @"print",
        @"block": ^id(NSArray *args, NSObject **returnValue) {
            didRun = YES;

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                *returnValue = @YES;
            });

            return nil;
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

@end
