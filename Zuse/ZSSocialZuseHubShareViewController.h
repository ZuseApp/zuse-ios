//
//  ZSSocialZuseHubShareViewController.h
//  Zuse
//
//  Created by Sarah Hong on 4/12/14.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSProject.h"

@interface ZSSocialZuseHubShareViewController : UIActivityViewController
@property (strong, nonatomic) ZSProject *project;
@property (copy, nonatomic) void(^didFinish)();

- (id)initWithProject:(ZSProject *)project;

@end
