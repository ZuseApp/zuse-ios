//
//  ZSSpriteTraits.m
//  Zuse
//
//  Created by Michael Hogenson on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSpriteTraits.h"

@implementation ZSSpriteTraits

+(NSDictionary *) defaultTraits {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"default_traits" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    return json;
}

@end
