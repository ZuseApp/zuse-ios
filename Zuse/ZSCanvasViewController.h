//
//  ZSCanvasViewController.h
//  Zuse
//
//  Created by Michael Hogenson on 10/1/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSProject.h"

@interface ZSCanvasViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) ZSProject *project;
@property (copy, nonatomic) void(^didFinish)();

@end
