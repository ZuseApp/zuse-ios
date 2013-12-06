//
//  ZSExpressionOptionsTableViewController.h
//  Zuse
//
//  Created by Parker Wightman on 12/4/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZSExpressionSelectionBlock)(id value);

typedef NS_OPTIONS(NSInteger, ZSExpressionType) {
    ZSExpressionTypeNumeric = 1 << 0,
    ZSExpressionTypeBoolean = 1 << 1,
    ZSExpressionTypeString  = 1 << 2,
    ZSExpressionTypeAny     = 0x7
};

typedef NS_OPTIONS(NSInteger, ZSExpressionValue) {
    ZSExpressionValueLiteral     = 1 << 0,
    ZSExpressionValueMethod      = 1 << 1,
    ZSExpressionValueProperty    = 1 << 2,
    ZSExpressionValueNewProperty = 1 << 3,
    ZSExpressionValueAny         = 0xf
};

@interface ZSExpressionOptionsTableViewController : UITableViewController

@property (assign, nonatomic) NSInteger expressionTypeMask;
@property (assign, nonatomic) NSInteger expressionValueMask;
@property (strong, nonatomic) NSArray *varNames;
@property (copy, nonatomic) ZSExpressionSelectionBlock didSelectValueBlock;

@end
