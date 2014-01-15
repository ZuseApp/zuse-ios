//
//  ZSGrid.h
//  Zuse
//
//  Created by Michael Hogenson on 1/15/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSGrid : NSObject

@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) CGSize dimensions;

- (CGSize)cellSize;
- (CGPoint)adjustedPointForPoint:(CGPoint)point;

@end
