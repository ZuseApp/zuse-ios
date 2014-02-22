#import "ZSToolboxCell.h"

@implementation ZSToolboxCell

// - (id)initWithFrame:(NSCoder *)aDecoder {
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _spriteView = [[ZSSpriteView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 17)];
        _spriteName = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 17, frame.size.width, 17)];
        _spriteName.font = [UIFont systemFontOfSize:12];
        _spriteName.textColor = [UIColor whiteColor];
        _spriteName.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_spriteView];
        [self addSubview:_spriteName];
    }
    return self;
}

@end
