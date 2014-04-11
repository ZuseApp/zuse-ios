// Copyright (c) 2013 Mutual Mobile (http://mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMSideDrawerSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@interface MMSideDrawerSectionHeaderView ()
@property (nonatomic, strong) UILabel * label;
@end

@implementation MMSideDrawerSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

            [self setBackgroundColor:[UIColor colorWithRed:100./255.0
                                                     green:103.0/255.0
                                                      blue:105.0/255.0
                                                     alpha:1.0]];
        
            _label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.bounds)-28,CGRectGetWidth(self.bounds)-30, 15)];

        
        if([[UIFont class] respondsToSelector:@selector(preferredFontForTextStyle:)]){
            [self.label setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
        }
        else {
             [self.label setFont:[UIFont boldSystemFontOfSize:12.0]];
        }
        
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setTextColor:[UIColor zuseYellow]];

            [self.label setShadowOffset:CGSizeMake(0, 1)];
            [self.label setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:.5]];
        
        [self.label setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:self.label];
        [self setClipsToBounds:NO];        
    }
    return self;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    [self.label setText:[self.title uppercaseString]];
}

@end
