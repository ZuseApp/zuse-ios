//
//  TCSpriteManager.h
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSpriteManager : NSObject

@property (strong, nonatomic) NSMutableArray *sprites;

+(id)sharedManager;

@end
