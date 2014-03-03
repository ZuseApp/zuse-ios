//
//  ZSZuseHubJSONClient.h
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface ZSZuseHubJSONClient : NSObject

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

+ (id)sharedClient;


@end
