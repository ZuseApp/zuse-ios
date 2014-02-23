#import "ZSStatementCell.h"

@implementation ZSStatementCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:10];
//        self.backgroundColor = [UIColor redColor];
        _statementView = [[ZS_StatementView alloc]initWithJson:nil];
        _nameView = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10)];
        _nameView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        _nameView.font = [UIFont systemFontOfSize:16];
        _nameView.textColor = [UIColor whiteColor];
        _nameView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameView];
        
        // Setup gesture recognizers.
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapRecognizer];
    }
    return self;
}

- (void)singleTapRecognized {
    if (_singleTapped) {
        _singleTapped();
    }
}

@end
