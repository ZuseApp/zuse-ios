//
//  ZSProgram.h
//  Zuse
//
//  Created by Michael Hogenson on 10/5/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSProgram : NSObject

@property(assign, nonatomic) CGFloat version;
@property(assign, nonatomic) CGFloat interpreterVersion;
@property(strong, nonatomic) NSMutableArray *sprites;

+ (ZSProgram *)dataWithFile:(NSString *)name;

-(void)writeToFile:(NSString *)name;
-(NSDictionary *) projectJSON;

@end
