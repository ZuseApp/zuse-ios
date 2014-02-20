//
//  ZSAdjustView.m
//  Zuse
//
//  Created by Michael Hogenson on 1/18/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSAdjustView.h"

@interface ZSAdjustView ()

@end

@implementation ZSAdjustView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (IBAction)exitButtonTapped:(id)sender {
    if (_exitTapped) {
        _exitTapped();
    }
}


//- (IBAction)showGridPanel:(id)sender {
//    _gridPanel.hidden = NO;
//    _positionPanel.hidden = YES;
//}
//
//- (IBAction)showPositionPanel:(id)sender {
//    _positionPanel.hidden = NO;
//    _gridPanel.hidden = YES;
//}
//
//
//- (IBAction)gridWidthChanged:(id)sender {
//    ZSCanvasView *view = (ZSCanvasView *)self.view;
//    UIStepper *slider = (UIStepper*)sender;
//    CGSize size = view.grid.dimensions;
//    size.width = view.grid.size.width / slider.value;
//    view.grid.dimensions = size;
//    NSInteger value = slider.value;
//    _gridWidth.text = [NSString stringWithFormat:@"%li", (long)value];
//    [view setNeedsDisplay];
//}
//
//- (IBAction)gridHeightChanged:(id)sender {
//    ZSCanvasView *view = (ZSCanvasView *)self.view;
//    UIStepper *slider = (UIStepper*)sender;
//    CGSize size = view.grid.dimensions;
//    size.height = view.grid.size.height / slider.value;
//    view.grid.dimensions = size;
//    NSInteger value = slider.value;
//    _gridHeight.text = [NSString stringWithFormat:@"%li", (long)value];
//    [view setNeedsDisplay];
//}

@end
