//
//  TCSpriteView.m
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "TCSpriteView.h"

@implementation TCSpriteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchesBegan) _touchesBegan([touches anyObject]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   if (_touchesMoved) _touchesMoved([touches anyObject]);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   if (_touchesEnded) _touchesEnded([touches anyObject]);

}
@end
