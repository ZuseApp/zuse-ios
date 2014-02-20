//
//  ZSSpriteController.h
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSSpriteController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) void(^longPressBegan)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressChanged)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressEnded)(UILongPressGestureRecognizer *longPressGestureRecognizer);

@end
