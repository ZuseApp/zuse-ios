//
//  ZSMenuController.h
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSMenuController : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) void(^playSelected)();
@end
