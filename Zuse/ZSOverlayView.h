//
//  ZSOverlayView.h
//  Zuse
//
//  Created by Michael Hogenson on 2/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSOverlayView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect activeRegion;
@property (nonatomic, assign) BOOL invertActiveRegion;

@end
