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
//        if(![_zuseHubSharedManager authenticateUser])
//            [_zuseHubSharedManager registerUser];
//        else
//            [_zuseHubSharedManager authenticateUser];
//        [_zuseHubSharedManager setAuthHeader];
    });
    
    return _zuseHubSharedManager;
}

- (NSArray *)getNewestProjects
{
    NSDictionary *params = @{@"?category=": @"newest"};
    __block NSArray *result = nil;
    [self.manager GET:@"projects.json"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, NSArray *project)
              {
                  result = project;
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  NSLog(@"Failed to get newest projects! %@", error.localizedDescription);
              }
     ];
    
    return result;
}

- (BOOL)registerUser
{
    //TODO make the user info generic
    NSDictionary *params = @{
                             @"user": @{
                                     @"username": @"sarahdemo",
                                     @"email": @"rollingstar.15@gmail.com",
                                     @"password": @"12345",
                                     @"confirm_password": @"12345"
                                     }
                             };
    
    [self.manager POST:@"user/register.json"
            parameters:params
            success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
            {
                self.token = responseObject[@"token"];
                //TODO get teh uuid from the user's actual info
                self.uuid = @"sarahdemo";
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Failed to register user! %@", error.localizedDescription);
            }];
    
    if(self.token)
        return YES;
    return NO;
}

- (BOOL)authenticateUser
{
    //TODO make the user info generic
    NSDictionary *params = @{
                             @"user" : @{
                                     @"username" : @"sarahdemo",
                                     @"password" : @"12345"
                                       }
                             };
    
    [self.manager POST:@"user/auth.json"
            parameters:params
            success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
            {
                self.token = responseObject[@"token"];
                //TODO get teh uuid from the user's actual info
                self.uuid = @"sarahdemo";
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Failed to authenticate user! %@", error.localizedDescription);
            }
     ];
    
    if(self.token)
        return YES;
    return NO;
}

- (void)setAuthHeader
{
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithToken:self.token];
}

- (NSArray *)getUsersSharedProjects
{
    __block NSArray *result = nil;
    [self.manager GET:@"user/projects.json"
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSArray *projects)
     {
         result = projects;
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failed to get user's shared projects! %@", error.localizedDescription);
     }
     ];

    
    return result;
}

- (BOOL)createSharedProject:(NSString *)title description:(NSString *)description uuid:(NSString *)uuid projectJson:(NSString *)projectJson compiledCode:(NSString *)compiledCode

{
    __block BOOL result = YES;
    
    NSData *projectData = [NSJSONSerialization dataWithJSONObject:projectJson
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];
    NSString *projectString = [[NSString alloc] initWithBytes:projectData.bytes
                                                       length:projectData.length
                                                     encoding:NSUTF8StringEncoding];
    
    NSData *compiledData = [NSJSONSerialization dataWithJSONObject:compiledCode
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];
    NSString *compiledString = [[NSString alloc] initWithBytes:compiledData.bytes
                                                       length:compiledData.length
                                                     encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{
        @"project" : @{
            @"title" : title,
            @"description" : description,
            @"uuid" : uuid,
            @"project_json" : projectString,
            @"compiled_code" : compiledString
        }
        };
    [self.manager POST:@"projects.json"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id project)
     {
         result = YES;
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failed to create a shared project! %@", error.localizedDescription);
         result = NO;
     }
     ];
    return result;
}

@end
