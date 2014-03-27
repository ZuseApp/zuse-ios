//
//  ZSTimedEvent.h
//  Zuse
//
//  Created by Parker Wightman on 3/25/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSTimedEvent : NSObject

@property (assign, nonatomic) NSInteger interval;
@property (assign, nonatomic) NSTimeInterval nextTime;
@property (strong, nonatomic) NSString *objectIdentifier;
@property (strong, nonatomic) NSString *eventIdentifier;

@end
