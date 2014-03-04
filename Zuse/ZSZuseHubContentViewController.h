//
//  ZSZuseHubContentViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSZuseHubJSONClient.h"

@interface ZSZuseHubContentViewController : UIViewController

@property NSInteger contentType;
@property (strong, nonatomic) ZSZuseHubJSONClient *manager;

- (void)contentSizeDidChange:(NSString*)size;

@end
