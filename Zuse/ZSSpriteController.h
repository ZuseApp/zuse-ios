//
//  ZSSpriteController.h
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSSpriteController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) void(^panBegan)(UIPanGestureRecognizer *panGestureRecognizer, NSDictionary *json);
@property (strong, nonatomic) void(^panMoved)(UIPanGestureRecognizer *panGestureRecognizer, NSDictionary *json);
@property (strong, nonatomic) void(^panEnded)(UIPanGestureRecognizer *panGestureRecognizer, NSDictionary *json);

@end
