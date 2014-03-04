//
//  ZSZuseHubJSONClient.h
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@protocol ZSZuseHubJSONClientDelegate;

@interface ZSZuseHubJSONClient : NSObject

@property(weak) id<ZSZuseHubJSONClientDelegate> delegate;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *jsonRequestSerializer;
@property (strong, nonatomic) AFJSONResponseSerializer *jsonResponseSerializer;
@property (strong, nonatomic) NSString *token;

+ (ZSZuseHubJSONClient *)sharedClient;
- (NSArray *)getNewestProjects;
- (BOOL)registerUser;
- (BOOL)authenticateUser;
- (void)setAuthHeader;

@end

@protocol ZSZuseHubJSONClientDelegate <NSObject>
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didUpdateWithProject:(id)project;
-(void)zuseHubHTTPClient:(ZSZuseHubJSONClient *)client didFailWithError:(NSError *)error;
@end
