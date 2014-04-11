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
    NSURL *url = [NSURL URLWithString:@"http://zusehub.com/api/v1/"];
    
    static ZSZuseHubJSONClient *_zuseHubSharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _zuseHubSharedManager = [[self alloc] init];
        _zuseHubSharedManager.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        _zuseHubSharedManager.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _zuseHubSharedManager.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    [_zuseHubSharedManager setUserTokenProperty];
    
    return _zuseHubSharedManager;
}

/**
 * Helper to set the token if one exists and to set the authentication header for requests
 */
- (void)setUserTokenProperty
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.token = [defaults objectForKey:@"token"];
    if(self.token)
    {
        [self setAuthHeader:self.token];
    }
}

//GENERAL

/**
 * Gets the 10 newest projects shared on ZuseHub
 */
- (void)getNewestProjects:(NSInteger)page itemsPerPage:(NSInteger)itemsPerPage completion:(void (^)(NSArray *))completion
{
    NSString *pageUrl = [@"&page=" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)page]];
    NSString *itemsUrl = [@"&per_page=" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)itemsPerPage]];
    NSString *url = [[@"projects.json?category=newest" stringByAppendingString:pageUrl] stringByAppendingString:itemsUrl];
    [self.manager GET:url
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSArray *projects)
              {
                  completion(projects);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  NSLog(@"Failed to get newest projects! %@", error.localizedDescription);
                  completion(nil);
              }
     ];
}

/**
 * Gets the 10 popular projects shared on ZuseHub
 */
- (void)getPopularProjects:(NSInteger)page itemsPerPage:(NSInteger)itemsPerPage completion:(void (^)(NSArray *))completion
{
    NSString *pageUrl = [@"&page=" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)page]];
    NSString *itemsUrl = [@"&per_page=" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)itemsPerPage]];
    NSString *url = [[@"projects.json?category=popular" stringByAppendingString:pageUrl] stringByAppendingString:itemsUrl];

    [self.manager GET:url
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSArray *projects)
     {
         completion(projects);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failed to get popular projects! %@", error.localizedDescription);
         completion(nil);
     }
     ];
}

/**
 * Download the specified project
 */
- (void)downloadProject:(NSString *)uuid completion:(void (^)(NSDictionary *))completion
{
    NSString *url = [[@"projects/" stringByAppendingString:uuid] stringByAppendingString:@"/download.json"];
    [self.manager GET:url
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSDictionary *project) {
                  completion(project);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Failed to download project! %@", error.localizedDescription);
                  completion(nil);
              }];
}

/**
 * Gets the project details for a specific project
 */
- (void)showProjectDetail:(NSString *)uuid completion:(void (^)(NSDictionary *))completion
{
    NSString *url = [[@"projects/" stringByAppendingString:uuid] stringByAppendingString:@".json"];
    [self.manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *project) {
        completion(project);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil);
    }];
}

//AUTHENTICATION/REGISTRATION

/**
 * Registers a user with ZuseHub
 */
- (void)registerUser:(NSDictionary *)loginInfo completion:(void (^)(NSDictionary *))completion
{
    //TODO make the user info generic
    NSDictionary *params = @{
                             @"user": @{
                                     @"username" : loginInfo[@"username"],
                                     @"email" : loginInfo[@"email"],
                                     @"password" : loginInfo[@"password"],
                                     @"password_confirmation" : loginInfo[@"password"]
                                     }
                             };
    
    [self.manager POST:@"user/register.json"
            parameters:params
            success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject)
            {
                completion(responseObject);
                [self setToken];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Failed to register user! %@", error.localizedDescription);
                completion(nil);
            }];
}

/**
 * Get the user token for registered users.
 */
- (void)authenticateUser:(NSDictionary *)loginInfo completion:(void(^)(NSDictionary *response))completion
{
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
                [self setToken];
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
    [self.manager.requestSerializer setValue:[@"Token: " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
}

/**
 * Helper to store the token
 */
- (void)setToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.token forKey:@"token"];
    [defaults synchronize];
}

//USER SPECIFIC

/**
 * Returns a list of the shared projects the user has put on ZuseHub
 */
- (void)getUsersSharedProjects:(NSInteger)page itemsPerPage:(NSInteger)itemsPerPage completion:(void (^)(NSArray *, NSInteger))completion
{
    NSString *pageUrl = [@"&page=" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)page]];
    NSString *itemsUrl = [@"&per_page=" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)itemsPerPage]];
    NSString *url = [[@"user/projects.json?" stringByAppendingString:pageUrl] stringByAppendingString:itemsUrl];
    [self.manager GET:url
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, NSArray *projects)
     {
         completion(projects, operation.response.statusCode);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Failed to get user's shared projects! %@", error.localizedDescription);
         completion(nil, operation.response.statusCode);
     }
     ];
}

/**
 * Gets a specific shared project by the user to show the project
 */
- (void)getUsersSharedSingleProject:(NSString *)uuid completion:(void (^)(NSDictionary *, NSInteger))completion
{
    NSString *url = [[@"user/projects/" stringByAppendingString:uuid] stringByAppendingString:@".json"];
    [self.manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *project) {
        completion(project, operation.response.statusCode);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to get specific project by the user! %@", error.localizedDescription);
        completion(nil, operation.response.statusCode);
    }];
}

/**
 * Shares a project for the first time.
 */
- (void)createSharedProject:(NSString *)title
                description:(NSString *)description
                projectJson:(ZSProject *)project
                 completion:(void (^)(NSDictionary *project, NSError *error, NSInteger statusCode))completion

{
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
            @"uuid" : uuid,
            @"project_json" : projectString,
            @"compiled_components" : compiledString,
            @"screenshot" : base64Screenshot
        }
        };
    [self.manager POST:@"user/projects.json"
            parameters:params
               success:^(AFHTTPRequestOperation *operation, NSDictionary *project)
     {
         completion(project, nil, operation.response.statusCode);
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         completion(nil, error, operation.response.statusCode);
         
         NSLog(@"Failed to create a shared project! %@", error.localizedDescription);
         NSLog(@"error string for sharing project failure %@", error.localizedFailureReason);
     }
     ];
}

/**
 * Deletes the project the user shared from ZuseHub
 */
- (void)deleteSharedProject:(NSString *)uuid completion:(void (^)(BOOL, NSInteger))completion
{
    NSString *url = [[@"user/projects/" stringByAppendingString:uuid] stringByAppendingString:@".json"];
    [self.manager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(YES, operation.response.statusCode);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to delete shared project! %@", error.localizedDescription);
        completion(NO, operation.response.statusCode);
    }];
}

/**
 * Updates a project that has already been shared
 */
- (void)updateSharedProject:(NSString *)title description:(NSString *)description projectJson:(ZSProject *)project completion:(void (^)(NSDictionary *, NSError *, NSInteger))completion
{
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
    
    NSString *version = project.version;
    
    NSString *base64Screenshot = [UIImagePNGRepresentation(project.screenshot) base64EncodedStringWithOptions:0];
    
    NSDictionary *params = @{
                             @"project" : @{
                                     @"title" : title,
                                     @"description" : description,
                                     @"project_json" : projectString,
                                     @"compiled_components" : compiledString,
                                     @"screenshot" : base64Screenshot,
                                     @"commit_number" : version
                                     }
                             };
    NSString *url = [[@"user/projects/" stringByAppendingString:uuid] stringByAppendingString:@".json"];
    
    [self.manager PUT:url
           parameters:params
              success:^(AFHTTPRequestOperation *operation, NSDictionary *project)
    {
        completion(project, nil, operation.response.statusCode);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to update project! %@", error.localizedDescription);
        completion(nil, error, operation.response.statusCode);
    }];
}

@end
