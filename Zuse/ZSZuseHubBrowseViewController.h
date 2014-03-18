//
//  ZSZuseHubBrowseViewController.h
//  Zuse
//
//  Created by Sarah Hong on 3/3/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSZuseHubContentViewController.h"
#import "ZSZuseHubEnums.h"

@interface ZSZuseHubBrowseViewController : ZSZuseHubContentViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (copy, nonatomic) void(^didDownloadProject)(ZSProject *project);

@end
