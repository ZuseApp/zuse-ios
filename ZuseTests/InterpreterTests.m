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
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@"Hello World!", args[0], @"");
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
        @"method":  @"print",
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
        @"block": ^(NSArray *args) {
            didRun = YES;
        }
    };
    
    [_interpreter loadMethod:method];
    
    [_interpreter loadObject:@{
        @"id": @"foo",
        @"properties": @[],
        @"code": @[
            @{
                @"on_event": @{
                    @"name": @"start",
                    @"code": @[
                        @{ @"call": @{ @"method": @"test", @"parameters": @[] } }
                    ]
                }
            }
        ]
    }];
    
    [_interpreter triggerEvent:@"start"];
    
    XCTAssert(didRun, @"");
}

- (void)testSimpleExpression {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"method":  @"print",
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@3, args[0], @"");
        }
    };
    
    [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"parameters": @[ @{ @"+": @[ @1, @2 ] } ]
        }
    };
    
    [_interpreter runJSON:program];
    
    XCTAssertEqual(YES, didRun, @"");
}

- (void)testNestedExpression {
    __block BOOL didRun = NO;
    
    NSDictionary *method = @{
        @"method":  @"print",
        @"block": ^(NSArray *args) {
            didRun = YES;
            XCTAssertEqualObjects(@6, args[0], @"");
        }
    };
    
   [_interpreter loadMethod:method];
    
    NSDictionary *program = @{
        @"call": @{
            @"method": @"print",
            @"parameters": @[
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
        @"method":  @"print",
        @"block": ^(NSArray *args, void(^finishedBlock)(id)) {
            didRun = YES;
            
            finishedBlock(@YES);
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
    NSDictionary *method = @{
        @"method":  @"check1",
        @"block": ^id(NSArray *args) {
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqualObjects(args[1], @"bar", @"");
            return @YES;
        }
    };
    
    [_interpreter loadMethod:method];
    
    method = @{
        @"method":  @"check2",
        @"block": ^id(NSArray *args) {
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqual(args[1], [NSNull null], @"");
            return @YES;
        }
    };

    [_interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"scope"];
    
    for (NSDictionary *dict in json[@"objects"]) {
        [_interpreter loadObject:dict];
    }
}

- (void)testEventScope {
    NSDictionary *method = @{
        @"method":  @"check1",
        @"block": ^id(NSArray *args) {
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqualObjects(args[1], @"bar", @"");
            return @YES;
        }
    };
    
    [_interpreter loadMethod:method];
    
    method = @{
        @"method":  @"check2",
        @"block": ^id(NSArray *args) {
            XCTAssertEqual(args.count, [@2 unsignedIntegerValue], @"");
            XCTAssertEqualObjects(args[0], @"foo", @"");
            XCTAssertEqual(args[1], [NSNull null], @"");
            return @YES;
        }
    };

    [_interpreter loadMethod:method];
    
    NSDictionary *json = [self loadTestFileAtPath:@"events_scope"];
    
    for (NSDictionary *dict in json[@"objects"]) {
        [_interpreter loadObject:dict];
    }
    
    [_interpreter triggerEvent:@"my_event" onObjectWithIdentifier:@"my_object"];
}

@end
