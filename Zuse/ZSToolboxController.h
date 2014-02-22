//
//  ZSToolboxController.h
//  Zuse
//
//  Created by Michael Hogenson on 2/20/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSToolboxController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger groupIndex;
@property (strong, nonatomic) void(^longPressBegan)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressChanged)(UILongPressGestureRecognizer *longPressGestureRecognizer);
@property (strong, nonatomic) void(^longPressEnded)(UILongPressGestureRecognizer *longPressGestureRecognizer);

@end
