//
//  ZSCodeTraverserTests.m
//  Zuse
//
//  Created by Parker Wightman on 3/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZSCodeTraverser.h"

@interface ZSCodeTraverserTests : XCTestCase

@end

@implementation ZSCodeTraverserTests

- (void)testCodeBlocksForObject {
    NSArray *codeBlocks = [ZSCodeTraverser codeBlocksForObject:@{
        @"object": @{
            @"code": @[
                @{ @"get": @"foo" }
            ]
        }
    }];
    
    XCTAssertEqual((NSUInteger)1, codeBlocks.count, @"");
    XCTAssertEqual((NSUInteger)1, ([codeBlocks[0] count]), @"");
}

- (void)testSetCodeBlocksForObject {
    NSDictionary *code = @{
        @"object": @{
            @"code": @[
                @{ @"get": @"foo" }
            ]
        }
    };
    
    NSDictionary *actual = [ZSCodeTraverser codeItemBySettingCodeBlocks:@[@[@{ @"get": @"bar" }]] forObject:code];
    
    NSDictionary *expected =@{
        @"object": @{
            @"code": @[
                @{ @"get": @"bar" }
            ]
        }
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

- (void)testCodeBlocksForOnEvent {
    NSArray *codeBlocks = [ZSCodeTraverser codeBlocksForOnEvent:@{
        @"on_event": @{
            @"name": @"blah",
            @"parameters": @[],
            @"code": @[
                @{ @"get": @"foo" }
            ]
        }
    }];
    
    XCTAssertEqual((NSUInteger)1, codeBlocks.count, @"");
    XCTAssertEqual((NSUInteger)1, ([codeBlocks[0] count]), @"");
}

- (void)testSetCodeBlocksForOnEvent {
    NSDictionary *code = @{
        @"on_event": @{
            @"name": @"blah",
            @"parameters": @[],
            @"code": @[
                @{ @"get": @"foo" }
            ]
        }
    };
    
    NSDictionary *actual = [ZSCodeTraverser codeItemBySettingCodeBlocks:@[@[@{ @"get": @"bar" }]] forOnEvent:code];
    
    NSDictionary *expected = @{
        @"on_event": @{
            @"name": @"blah",
            @"parameters": @[],
            @"code": @[
                @{ @"get": @"bar" }
            ]
        }
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

- (void)testCodeBlocksForSuite {
    NSArray *codeBlocks = [ZSCodeTraverser codeBlocksForSuite:@{
        @"suite": @[
            @{ @"get": @"foo" }
        ]
    }];
    
    XCTAssertEqual((NSUInteger)1, codeBlocks.count, @"");
    XCTAssertEqual((NSUInteger)1, ([codeBlocks[0] count]), @"");
}

- (void)testSetCodeBlocksForSuite {
    NSDictionary *code = @{
        @"suite": @[
            @{ @"get": @"foo" }
        ]
    };
    
    NSDictionary *actual = [ZSCodeTraverser codeItemBySettingCodeBlocks:@[@[@{ @"get": @"bar" }]] forSuite:code];
    
    NSDictionary *expected = @{
        @"suite": @[
            @{ @"get": @"bar" }
        ]
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

- (void)testCodeBlocksForIf {
    NSArray *codeBlocks = [ZSCodeTraverser codeBlocksForIf:@{
        @"if": @{
            @"test": @YES,
            @"true": @[
                @{ @"set": @[@"this", @"that"] }
            ],
            @"false": @[
                @{ @"get": @"this" }
            ]
        }
    }];
    
    XCTAssertEqual((NSUInteger)2, codeBlocks.count, @"");
    XCTAssertEqual((NSUInteger)1, ([codeBlocks[0] count]), @"");
    XCTAssertEqual((NSUInteger)1, ([codeBlocks[1] count]), @"");
}

- (void)testSetCodeBlocksForIf {
    NSDictionary *code = @{
        @"if": @{
            @"test": @YES,
            @"true": @[
                @{ @"set": @[@"this", @"that"] }
            ],
            @"false": @[
                @{ @"get": @"this" }
            ]
        }
    };
    
    NSDictionary *actual = [ZSCodeTraverser codeItemBySettingCodeBlocks:@[@[@{ @"get": @"bar" }], @[@{ @"get": @"baz" }]] forIf:code];
    
    NSDictionary *expected = @{
        @"if": @{
            @"test": @YES,
            @"true": @[
                @{ @"get": @"bar" }
            ],
            @"false": @[
                @{ @"get": @"baz" }
            ]
        }
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

- (void)testMapBlockNested
{
    NSDictionary *code = @{
        @"suite": @[
            @{
                @"if": @{
                    @"test": @YES,
                    @"true": @[
                        @{
                            @"object": @{
                                @"code": @[
                                    @{ @"set": @[@"foo", @2] },
                                    @{
                                        @"suite": @[
                                            @{ @"get": @"foo" }
                                        ]
                                    },
                                ]
                            }
                        }
                    ],
                    @"false": @[
                        @{ @"get": @"hi" }
                    ]
                }
            }
        ]
    };
    
    __block NSInteger timesCalled = 0;
    
    NSMutableArray *statements = [@[@"suite", @"if", @"object", @"set", @"suite", @"get", @"get"] mutableCopy];
    
    [ZSCodeTraverser map:code block:^NSDictionary *(NSDictionary *codeItem) {
        NSString *key = codeItem.allKeys.firstObject;
        NSInteger index = [statements indexOfObject:key];
        XCTAssertNotEqual(NSNotFound, index, @"");
        [statements removeObjectAtIndex:index];
        timesCalled++;
        return codeItem;
    }];
    
    XCTAssertEqual((NSUInteger)0, statements.count, @"");
    XCTAssertEqual(7, timesCalled, @"");
}

- (void)testMapBlockReplacesItems {
    NSDictionary *code = @{
        @"if": @{
            @"test": @YES,
            @"true": @[
                @{ @"set": @[@"this", @"that"] }
            ],
            @"false": @[
                @{ @"get": @"this" }
            ]
        }
    };
    
    NSDictionary * actual = [ZSCodeTraverser map:code block:^NSDictionary *(NSDictionary *codeItem) {
        if ([codeItem.allKeys.firstObject isEqualToString:@"if"]) {
            return codeItem;
        } else {
            return @{};
        }
    }];
    
    NSDictionary *expected = @{
        @"if": @{
            @"test": @YES,
            @"true": @[
                @{}
            ],
            @"false": @[
                @{}
            ]
        }
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

- (void)testMapWithKeyUsingBlock {
    NSDictionary *code = @{
        @"suite": @[
            @{ @"get": @"foo" },
            @{ @"foo": @"foo" },
            @{ @"set": @[@"this", @1] }
        ]
    };

    NSDictionary *actual = [ZSCodeTraverser map:code onKeys:@[@"set", @"foo"] block:^NSDictionary *(NSDictionary *codeItem) {
        return @{ @"get": @"bar" };
    }];
    
    NSDictionary *expected = @{
        @"suite": @[
            @{ @"get": @"foo" },
            @{ @"get": @"bar" },
            @{ @"get": @"bar" },
        ]
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

- (void)testFilterBlock {
    NSDictionary *code = @{
        @"suite": @[
            @{ @"get": @"foo" },
            @{ @"foo": @"foo" },
            @{ @"set": @[@"this", @1] }
        ]
    };

    NSDictionary *actual = [ZSCodeTraverser filter:code block:^BOOL(NSDictionary *codeItem) {
        return ![codeItem.allKeys.firstObject isEqualToString:@"foo"];
    }];
    
    NSDictionary *expected = @{
        @"suite": @[
            @{ @"get": @"foo" },
            @{ @"set": @[@"this", @1] }
        ]
    };
    
    XCTAssertEqualObjects(expected, actual, @"");
}

@end
