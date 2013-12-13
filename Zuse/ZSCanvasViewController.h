//
//  ZSCanvasViewController.h
//  Zuse
//
//  Created by Michael Hogenson on 10/1/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSCanvasViewController : UIViewController <UIGestureRecognizerDelegate>

// @"new_project.json"
@property (strong, nonatomic) NSString *projectPath;
@property (copy, nonatomic) void(^didFinish)();

@end
