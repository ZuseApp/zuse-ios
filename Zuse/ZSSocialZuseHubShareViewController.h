//
//  ZSSocialZuseHubShareViewController.h
//  Zuse
//
//  Created by Sarah Hong on 4/12/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSSocialZuseHubShareViewController : UIActivityViewController

@property (copy, nonatomic) void(^didFinish)();

@end