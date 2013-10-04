//
//  ZSSuiteController.h
//  Zuse
//
//  Created by Michael Hogenson on 10/2/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSSuiteController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *suite;

@end
