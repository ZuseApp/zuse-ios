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

+ (void)initialize
{
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


+ (NSString *)userLoginDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDocumentsPath = [documentsDirectory stringByAppendingPathComponent:[ZSTokenPersistenceProjectsFolder copy]];
    return userDocumentsPath;
}

+ (NSString *)getTokenInfo
{
    NSData *tokenData = [NSData dataWithContentsOfFile:[ZSAuthTokenPersistence pathForToken]];
    
    if(tokenData)
    {
        NSString *tokenInfo = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
        return tokenInfo;
    }
    return nil;
}

+ (NSString *)pathForToken
{
    NSString *filename = [@"tokenInfo" stringByAppendingPathExtension:@"txt"];
    return [[self userLoginDirectoryPath] stringByAppendingPathComponent:filename];
}

+ (void)writeTokenInfo:(NSString *)token
{
    static dispatch_queue_t savingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        savingQueue = dispatch_queue_create("com.zuse.zs_token_persistence.saving", DISPATCH_QUEUE_SERIAL);
    });

    NSString *tokenPath = [self pathForToken];
    dispatch_async(savingQueue, ^{
        NSError *error;
        BOOL succeed = [token writeToFile:tokenPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if(!succeed)
        {
            NSLog(@"Error writing token to file");
        }
    });

}

@end
