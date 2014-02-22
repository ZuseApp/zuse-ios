//
//  ZSSpriteLibrary.h
//  Zuse
//
//  Created by Michael Hogenson on 12/6/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSSpriteLibrary : NSObject

@property (nonatomic, strong) NSMutableArray *categories;

+ (ZSSpriteLibrary*)sharedLibrary;

@end
