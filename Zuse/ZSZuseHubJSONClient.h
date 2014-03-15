//
//  ZSZuseHubJSONClient.h
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ZSProject.h"

@protocol ZSZuseHubJSONClientDelegate;

@interface ZSZuseHubJSONClient : NSObject

@property(weak) id<ZSZuseHubJSONClientDelegate> delegate;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *jsonRequestSerializer;
@property (strong, nonatomic) AFJSONResponseSerializer *jsonResponseSerializer;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *uuid;

+ (ZSZuseHubJSONClient *)sharedClient;
- (void )getNewestProjects:(void(^)(NSArray *projects))completion;
- (void)registerUser:(void(^)(NSDictionary *response))completion;
- (void)authenticateUser:(void(^)(NSDictionary *response))completion;;
- (void)setAuthHeader;
- (void)getUsersSharedProjects:(void(^)(NSArray *projects))completion;
- (void)createSharedProject:(NSString *)title description:(NSString *)description projectJson:(ZSProject *)projectJson completion:(void(^)(NSError *))completion;

@end

@protocol ZSZuseHubJSONClientDelegate <NSObject>
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didUpdateWithProject:(id)project;
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didFailWithError:(NSError *)error;
@end
