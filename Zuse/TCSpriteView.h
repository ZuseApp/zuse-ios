//
//  TCSpriteView.h
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSprite.h"

@interface TCSpriteView : UIImageView

@property (strong, nonatomic) void(^touchesBegan)(UITouch *touch);
@property (strong, nonatomic) void(^touchesMoved)(UITouch *touch);
@property (strong, nonatomic) void(^touchesEnded)(UITouch *touch);
@property (strong, nonatomic) TCSprite *sprite;

@end
