//
//  ZSProjectPersistence.m
//  Zuse
//
//  Created by Parker Wightman on 2/27/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSProjectPersistence.h"
#import "BlocksKit.h"
#import "ZSProject.h"

NSString const * ZSProjectPersistenceScreenshotsFolder = @"UserScreenshots";
NSString const * ZSProjectPersistenceProjectsFolder = @"UserProjects";

@implementation ZSProjectPersistence

+ (void)initialize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[self userProjectsDirectoryPath]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self userProjectsDirectoryPath]
               withIntermediateDirectories:YES
                                attributes:@{}
                                     error:&error];
        
        if (error) {
            NSLog(@"+ [ZSProjectPersistence initialize]: Could not create directory at path: %@", [self userProjectsDirectoryPath]);
        }
    }
    
    if (![fileManager fileExistsAtPath:[self userScreenshotsDirectoryPath]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self userScreenshotsDirectoryPath]
               withIntermediateDirectories:YES
                                attributes:@{}
                                     error:&error];
        
        if (error) {
            NSLog(@"+ [ZSProjectPersistence initialize]: Could not create directory at path: %@", [self userScreenshotsDirectoryPath]);
        }
    }
    
    NSLog(@"%@", [self userProjectsDirectoryPath]);
}

/**
 *  Full paths to example JSON files included in the bundle. Example project JSON should
 *  be of the form <name>_example.json.
 *
 *  @return Array of full paths to files
 */
+ (NSArray *)exampleProjectPaths {
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"json" inDirectory:@""];
    paths = [paths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    paths = [paths select:^BOOL(NSString *path) {
        return [path hasSuffix:@"_example.json"];
    }];
    return paths;
}

+ (NSArray *)exampleScreenshotPaths {
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@""];
    paths = [paths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    paths = [paths select:^BOOL(NSString *path) {
        return [path hasSuffix:@"_example.png"];
    }];
    return paths;
}

/**
 *  Full paths to all user-created projects
 *
 *  @return Array of NSString objects
 */
+ (NSArray *)userProjectPaths {
    return [self projectPathsInDirectory:[self userProjectsDirectoryPath]];
}

/**
 *  Returns paths to projecs from a specific directory
 *
 *  @param directoryPath Full path to the directory
 *
 *  @return Array of strings
 */
+ (NSArray *)projectPathsInDirectory:(NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
    
    if (error) {
        NSLog(@"+ [ZSProjectPersistence userProjectPaths]: Couldn't fetch contents of directory: %@\n%@", directoryPath, error.localizedDescription);
    }
    
    assert(!error);
    
    directoryContents = [directoryContents map:^id(NSString *filename) {
        return [directoryPath stringByAppendingPathComponent:filename];
    }];
    
    directoryContents = [directoryContents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *firstProperties = [fileManager attributesOfItemAtPath:obj1 error:nil];
        NSDictionary *secondProperties = [fileManager attributesOfItemAtPath:obj2 error:nil];
        
        NSDate *date1 = firstProperties[NSFileModificationDate];
        NSDate *date2 = secondProperties[NSFileModificationDate];
        
        return [date2 compare:date1];
    }];
    
    return directoryContents;
}

/**
 *  Returns array of ZSProject objects for example projects
 *
 *  @return Array of ZSProject objects
 */
+ (NSArray *)exampleProjects {
    NSArray *projectPaths = [self exampleProjectPaths];
    NSArray *screenshotPaths = [self exampleScreenshotPaths];
    NSMutableArray *projects = [NSMutableArray array];
    
    [projectPaths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        ZSProject *project = [ZSProject projectWithFile:path];
        project.screenshot = [UIImage imageWithContentsOfFile:screenshotPaths[idx]];
        [projects addObject:project];
    }];
    return projects;
}

/**
 *  Returns array of user-created ZSProject objects
 *
 *  @return Array of ZSProject objects
 */
+ (NSArray *)userProjects {
    return [[self userProjectPaths] map:^id(NSString *filePath) {
        ZSProject *project = [ZSProject projectWithFile:filePath];
        project.screenshot = [self screenshotForProject:project];
        return project;
    }];
}

/**
 *  Returns ZS Project objects for each path in filePaths
 *
 *  @param filePaths Array of file paths to JSON objects representing ZSProject objects
 *
 *  @return Array of ZSProject objects
 */
+ (NSArray *)projectsForPaths:(NSArray *)filePaths {
    return [filePaths map:^id(NSString *filePath) {
        return [ZSProject projectWithFile:filePath];
    }];
}

/**
 *  Given a ZSProject object, returns the full path it should be saved to on disk
 *
 *  @param project ZSProject object
 *
 *  @return Full path to save/load project
 */
+ (NSString *)pathForProject:(ZSProject *)project {
    NSString *filename = [project.identifier stringByAppendingPathExtension:@"json"];
    return [[self userProjectsDirectoryPath] stringByAppendingPathComponent:filename];
}

+ (NSString *)pathForScreenshotWithProject:(ZSProject *)project {
    NSString *filename = [project.identifier stringByAppendingPathExtension:@"png"];
    return [[self userScreenshotsDirectoryPath] stringByAppendingPathComponent:filename];
}

+ (UIImage *)screenshotForProject:(ZSProject *)project {
    UIImage *image = [UIImage imageWithContentsOfFile:[self pathForScreenshotWithProject:project]];
    return image;
}

/**
 *  Full path to directory holding user-created projects
 *
 *  @return Full path to directory
 */
+ (NSString *)userProjectsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDocumentsPath = [documentsDirectory stringByAppendingPathComponent:[ZSProjectPersistenceProjectsFolder copy]];
    return userDocumentsPath;
}

+ (NSString *)userScreenshotsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userDocumentsPath = [documentsDirectory stringByAppendingPathComponent:[ZSProjectPersistenceScreenshotsFolder copy]];
    return userDocumentsPath;
}

/**
 *  Writes project to disk. This method is thread-safe and can be called multiple times.
 *
 *  @param project Project to be saved.
 */
+ (void)writeProject:(ZSProject *)project {
    static dispatch_queue_t savingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        savingQueue = dispatch_queue_create("com.zuse.zs_project_persistence.saving", DISPATCH_QUEUE_SERIAL);
    });
    
    NSDictionary *assembledJSON = [[project assembledJSON] deepCopy];
    NSString *projectPath = [self pathForProject:project];
    NSString *screenshotPath = [self pathForScreenshotWithProject:project];
    dispatch_async(savingQueue, ^{
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:assembledJSON options:NSJSONWritingPrettyPrinted error:&error];
        if (!jsonData) {
            NSLog(@"Error serializing: %@", error);
        } else {
            [jsonData writeToFile:projectPath atomically:YES];
            
            NSData *screenshotData = UIImagePNGRepresentation(project.screenshot);
            [screenshotData writeToFile:screenshotPath atomically:YES];
        }
    });
}

@end
