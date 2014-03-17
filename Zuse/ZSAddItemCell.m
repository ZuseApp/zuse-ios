#import "ZSAddItemCell.h"
#import <FontAwesomeKit/FAKIcon.h>
#import <FontAwesomeKit/FAKIonIcons.h>

@implementation ZSAddItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        FAKIcon *icon = [FAKIonIcons plusRoundIconWithSize:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        
        UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
        plusButton.frame = CGRectMake(10, 10, frame.size.width - 20, frame.size.height - 20);
        plusButton.layer.borderColor = [[UIColor blackColor] CGColor];
        plusButton.layer.borderWidth = 0.5f;
        plusButton.layer.cornerRadius = 10;
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
