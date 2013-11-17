//
//  TCSpriteView.m
//  Zuse
//
//  Created by Michael Hogenson on 9/22/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "TCSpriteView.h"

typedef NS_ENUM(NSInteger, StateType) {
    STARTED,
    CANCELLED,
    EXECUTED
};

@interface TCSpriteView ()

@property (nonatomic, assign) StateType state;

@end

@implementation TCSpriteView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)cancelLongTap {
    _state = CANCELLED;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(detectedLongTap) object:nil];
    NSLog(@"Cancelled perform request");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch began");
    _state = STARTED;
    [self performSelector:@selector(detectedLongTap) withObject:nil afterDelay:1.0f];
    if (_touchesBegan) _touchesBegan([touches anyObject]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // If the long press hasn't been executed then cancel it, if it hasn't been already, and execute the touch moved.
    if (_state != EXECUTED) {
        if (_state != CANCELLED) {
            [self cancelLongTap];
        }
        NSLog(@"touch moved");
        if (_touchesMoved) _touchesMoved([touches anyObject]);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_state != EXECUTED) {
        [self cancelLongTap];
        NSLog(@"touch ended");
        if (_touchesEnded) _touchesEnded([touches anyObject]);
    }
}

- (void)detectedLongTap {
    NSLog(@"Long tap");
    _state = EXECUTED;
    if (_longTouch) _longTouch();
}

@end
