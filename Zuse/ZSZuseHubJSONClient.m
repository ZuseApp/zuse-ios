//
//  ZSZuseHubJSONClient.m
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubJSONClient.h"

@implementation ZSZuseHubJSONClient

+ (ZSZuseHubJSONClient *)sharedClient
{
    NSURL *url = [NSURL URLWithString:@"https://zusehub.herokuapp.com/api/v1/"];
    
    static ZSZuseHubJSONClient *_zuseHubSharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _zuseHubSharedManager = [[self alloc] init];
        _zuseHubSharedManager.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _zuseHubSharedManager.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _zuseHubSharedManager.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return _zuseHubSharedManager;
}

@end
