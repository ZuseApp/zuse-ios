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
- (void)getNewestProjects:(NSInteger)page itemsPerPage:(NSInteger)itemsPerPage completion:(void(^)(NSArray *projects))completion;
- (void)getPopularProjects:(NSInteger)page itemsPerPage:(NSInteger)itemsPerPage completion:(void(^)(NSArray *projects))completion;
- (void)downloadProject:(NSString *)uuid completion:(void(^)(NSDictionary *project))completion;
- (void)showProjectDetail:(NSString *)uuid completion:(void(^)(NSDictionary *project))completion;

//authentication registration
- (void)registerUser:(NSDictionary *)loginInfo completion:(void (^)(NSDictionary *))completion;
- (void)authenticateUser:(NSDictionary *)loginInfo completion:(void(^)(NSDictionary *response))completion;
- (void)setAuthHeader:(NSString *)token;

//user specific
- (void)getUsersSharedProjects:(NSInteger)page itemsPerPage:(NSInteger)itemsPerPage completion:(void(^)(NSArray *projects, NSInteger statusCode))completion;
- (void)getUsersSharedSingleProject:(NSString *) uuid completion:(void(^)(NSDictionary *project, NSInteger statusCode))completion;
- (void)createSharedProject:(NSString *)title description:(NSString *)description projectJson:(ZSProject *)projectJson completion:(void(^)(NSDictionary *project, NSError *error, NSInteger statusCode))completion;
- (void)deleteSharedProject:(NSString *)uuid completion:(void(^)(BOOL success, NSInteger statusCode ))completion;
- (void)updateSharedProject:(NSString *)title description:(NSString *)description projectJson:(ZSProject *)project completion:(void(^)(NSDictionary *project, NSError *error, NSInteger statusCode))completion;

//project sharing on social media
- (void)socialShare:(ZSProject *)project completion:(void(^)(NSString *url, NSInteger statusCode ))completion;
;

@end

@protocol ZSZuseHubJSONClientDelegate <NSObject>
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didUpdateWithProject:(id)project;
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didFailWithError:(NSError *)error;
@end
