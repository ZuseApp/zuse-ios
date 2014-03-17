//
//  ZSCodeTransforms.m
//  Zuse
//
//  Created by Parker Wightman on 3/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSCodeTransforms.h"

ZSCodeTransformBlock ZSCodeTransformEveryBlock = ^NSDictionary *(NSDictionary *codeItem) {
    NSString *eventID = [NSUUID.UUID UUIDString];
    return @{
        @"code": @[
            @{
                @"on_event": @{
                    @"name": eventID,
                    @"parameters": @[],
                    @"code": codeItem[@"every"][@"code"]
                }
            },
            @{
                @"call": @{
                    @"method": @"every_seconds",
                    @"parameters": @[codeItem[@"every"][@"seconds"], eventID]
                }
            }
        ]
    };
};