//
//  ZSZuseHubJSONClient.m
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSZuseHubJSONClient.h"
#import "ZSCompiler.h"

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

/**
 * Gets the 10 newest projects shared on ZuseHub
 */
- (void)getNewestProjects:(void(^)(NSArray *projects))completion
{
    [self.manager GET:@"projects.json?category=newest"
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSArray *projects)
              {
                  completion(projects);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  NSLog(@"Failed to get newest projects! %@", error.localizedDescription);
              }
     ];
}

/**
 * Registers a user with ZuseHub
 */
- (void)registerUser:(void (^)(NSDictionary *))completion loginInfo:(NSDictionary *)loginInfo
{
    //TODO make the user info generic
    NSDictionary *params = @{
                             @"user": @{
                                     @"username": loginInfo[@"username"],
                                     @"email": loginInfo[@"email"],
                                     @"password": loginInfo[@"password"],
                                     @"password_confirmation": loginInfo[@"password"]
                                     }
                             };
    
    [self.manager POST:@"user/register.json"
            parameters:params
            success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
            {
                completion(responseObject);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Failed to register user! %@", error.localizedDescription);
                completion(nil);
            }];
}

/**
 * Gets the user's token if the user has already logged in.
 */
- (void)authenticateUser:(NSDictionary *)loginInfo completion:(void(^)(NSDictionary *response))completion
{
    //TODO make the user info generic
    NSDictionary *params = @{
                             @"user" : @{
                                     @"username" : loginInfo[@"username"],
                                     @"password" : loginInfo[@"password"]
                                       }
                             };
    
    [self.manager POST:@"user/auth.json"
            parameters:params
            success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
            {
                completion(responseObject);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Failed to authenticate user! %@", error.localizedDescription);
                completion(nil);
            }
     ];
}

/**
 * Sets the token as the header for future requests
 */
- (void)setAuthHeader:(NSString *)token
{
//    NSString *params = [@"Token: " stringByAppendingString:self.token];
//    [self.manager.requestSerializer setValue:[@"Token: " stringByAppendingString:self.token]
//                          forHTTPHeaderField:@"Authorization"];
    
    [self.manager.requestSerializer setValue:[@"Token: " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
}

/**
 * Returns the shared projects the user has put on ZuseHub
 */
- (void)getUsersSharedProjects:(void (^)(NSArray *))completion
{
    [self.manager GET:@"user/projects.json"
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSArray *projects)
     {
         completion(projects);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failed to get user's shared projects! %@", error.localizedDescription);
         completion(nil);
     }
     ];
}

/**
 * Shares a project for the first time.
 */
- (void)createSharedProject:(NSString *)title
                description:(NSString *)description
                projectJson:(ZSProject *)project
                 completion:(void (^)(NSError *))completion

{
    __block BOOL result = YES;
    
    NSData *projectData = [NSJSONSerialization dataWithJSONObject:project.assembledJSON
                                                          options:0
                                                            error:nil];
    NSString *projectString = [[NSString alloc] initWithBytes:projectData.bytes
                                                       length:projectData.length
                                                     encoding:NSUTF8StringEncoding];
    ZSCompiler *compiler = [ZSCompiler compilerWithProjectJSON:project.assembledJSON];
    NSData *compiledData = [NSJSONSerialization dataWithJSONObject:compiler.compiledJSON
                                                          options:0
                                                            error:nil];
    NSString *compiledString = [[NSString alloc] initWithBytes:compiledData.bytes
                                                       length:compiledData.length
                                                     encoding:NSUTF8StringEncoding];
    NSString *uuid = project.identifier;
    
    NSString *base64Screenshot = [UIImagePNGRepresentation(project.screenshot) base64EncodedStringWithOptions:0];
    
    NSDictionary *params = @{
        @"project" : @{
            @"title" : title,
            @"description" : description,
            @"screenshot" : base64Screenshot,
            @"uuid" : uuid,
            @"project_json" : projectString,
            @"compiled_code" : compiledString
        }
        };
    [self.manager POST:@"user/projects.json"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id project)
     {
         completion(nil);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(error);
         NSLog(@"Failed to create a shared project! %@", error.localizedDescription);
         NSLog(@"error string for sharing project failure %@", error.localizedFailureReason);
         result = NO;
     }
     ];
}

@end
