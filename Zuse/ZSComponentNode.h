//
//  ZSComponentNode.h
//  Zuse
//
//  Created by Parker Wightman on 1/29/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "SKComponentNode.h"

@interface ZSComponentNode : SKComponentNode

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *group;
@property (strong, nonatomic) NSDictionary *JSON;

@end
