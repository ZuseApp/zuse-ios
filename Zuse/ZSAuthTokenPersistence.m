//
//  ZSAuthTokenPersistence.m
//  Zuse
//
//  Created by Sarah Hong on 3/10/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSAuthTokenPersistence.h"

NSString const * ZSTokenPersistenceProjectsFolder = @"UserAuthToken";

@implementation ZSAuthTokenPersistence

+ (void)initialize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[self userLoginDirectoryPath]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self userLoginDirectoryPath]
               withIntermediateDirectories:YES
                                attributes:@{}
                                     error:&error];
        
        if (error) {
            NSLog(@"+ [ZSAuthTokenPersistence initialize]: Could not create directory at path: %@", [self userLoginDirectoryPath]);
        }
    }
    
    NSLog(@"%@", [self userLoginDirectoryPath]);
}


+ (NSString *)userLoginDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDocumentsPath = [documentsDirectory stringByAppendingPathComponent:[ZSTokenPersistenceProjectsFolder copy]];
    return userDocumentsPath;
}

+ (NSDictionary *)getLoginInfo{
    NSData *loginData = [NSData dataWithContentsOfFile:[ZSAuthTokenPersistence pathForLogin]];
    
    if(loginData)
    {
        NSDictionary *loginInfo = [NSJSONSerialization JSONObjectWithData:loginData options:NSJSONReadingMutableContainers error:nil];
        return loginInfo;
    }
    return nil;
}

+ (NSString *)pathForLogin {
    NSString *filename = [@"loginInfo" stringByAppendingPathExtension:@"txt"];
    return [[self userLoginDirectoryPath] stringByAppendingPathComponent:filename];
}

+ (void)writeLoginInfo:(NSDictionary *)loginInfo {
    static dispatch_queue_t savingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        savingQueue = dispatch_queue_create("com.zuse.zs_project_persistence.saving", DISPATCH_QUEUE_SERIAL);
    });

    NSDictionary *loginInfoCopy = [loginInfo deepCopy];
    NSString *loginPath = [self pathForLogin];
    dispatch_async(savingQueue, ^{
        NSError *error;
        NSData *loginData = [NSJSONSerialization dataWithJSONObject:loginInfoCopy options:NSJSONWritingPrettyPrinted error:&error];
        if (!loginData) {
            NSLog(@"Error serializing: %@", error);
        } else {
            [loginData writeToFile:loginPath atomically:YES];
        }
    });

}

@end
