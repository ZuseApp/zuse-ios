#import "ZSAddItemCell.h"
#import <FontAwesomeKit/FAKIcon.h>
#import <FontAwesomeKit/FAKIonIcons.h>

@implementation ZSAddItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        FAKIcon *icon = [FAKIonIcons ios7PlusOutlineIconWithSize:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        
        UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
        plusButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        plusButton.showsTouchWhenHighlighted = YES;
        [plusButton setAttributedTitle:icon.attributedString forState:UIControlStateNormal];
        [plusButton addTarget:self action:@selector(singleTapRecognized) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:plusButton];
    }
    return self;
}

- (void)singleTapRecognized {
    if (self.singleTapped) {
        self.singleTapped();
    }
}

@end
