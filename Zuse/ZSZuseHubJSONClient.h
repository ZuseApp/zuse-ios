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

+ (ZSZuseHubJSONClient *)sharedClient;

//general
- (void )getNewestProjects:(void(^)(NSArray *projects))completion;
- (void )getPopularProjects:(void(^)(NSArray *projects))completion;
- (void )downloadProject:(NSString *)uuid completion:(void(^)(NSDictionary *project))completion;

//authentication registration
- (void)registerUser:(NSDictionary *)loginInfo completion:(void (^)(NSDictionary *))completion;
- (void)authenticateUser:(NSDictionary *)loginInfo completion:(void(^)(NSDictionary *response))completion;
- (void)setAuthHeader:(NSString *)token;

//user specific
- (void)getUsersSharedProjects:(void(^)(NSArray *projects))completion;
- (void)createSharedProject:(NSString *)title description:(NSString *)description projectJson:(ZSProject *)projectJson completion:(void(^)(NSError *))completion;

@end

@protocol ZSZuseHubJSONClientDelegate <NSObject>
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didUpdateWithProject:(id)project;
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didFailWithError:(NSError *)error;
@end
