#import "ZSToolboxView.h"
#import "FXBlurView.h"

@interface ZSToolboxView ()

@property (nonatomic, strong) NSMutableArray *collectionTitles;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *importButton;
@property (nonatomic, strong) FXBlurView *blurView;
@property (nonatomic, strong) UIScrollView *content;
@property (nonatomic, assign) BOOL wasAnimated;
@property (nonatomic, assign) BOOL pagingEnabled;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation ZSToolboxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pagingEnabled = YES;
        _buttons = [NSMutableArray array];
        
        self.hidden = YES;
        self.userInteractionEnabled = YES;
        [self.layer setCornerRadius:10];
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.95];
        
        // Title collections
        _collectionTitles = [NSMutableArray array];
        
        // Label
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:0.95];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        // Content
        _content = [[UIScrollView alloc] init];
        _content.userInteractionEnabled = YES;
        _content.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.95];
        _content.backgroundColor = [UIColor whiteColor];
        _content.pagingEnabled = YES;
        _content.showsHorizontalScrollIndicator = NO;
        _content.delegate = self;
        
        // Page Control
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.95];
        _pageControl.numberOfPages = 1;
        _pageControl.currentPage = 0;
        _pageControl.enabled = NO;
        
        // Import Button
//        _importButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        _importButton.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:0.95];
//        [_importButton setTintColor:[UIColor whiteColor]];
//        [_importButton setTitle:@"Import Image" forState:UIControlStateNormal];
        
        [self addSubview:_titleLabel];
        [self addSubview:_content];
        [self addSubview:_pageControl];
        [self addSubview:_importButton];
    }
    return self;
}

- (void)setPagingEnabled:(BOOL)enabled {
    _pagingEnabled = enabled;
    _content.pagingEnabled = _pagingEnabled;
    if (enabled && ![self.subviews containsObject:_pageControl]) {
        [self addSubview:_pageControl];
    }
    if (!enabled && [self.subviews containsObject:_pageControl]) {
        [_pageControl removeFromSuperview];
    }
}

- (UIView*)viewByIndex:(NSInteger)index {
    return _content.subviews[index];
}

- (void)showAnimated:(BOOL)animated {
    if (self.superview) {
        self.alpha = 0;
        self.hidden = NO;
        _blurView = [[FXBlurView alloc] initWithFrame:self.superview.frame];
        _blurView.alpha = 0;
        _blurView.hidden = NO;
        _blurView.blurRadius = 5;
        _blurView.tintColor = [UIColor clearColor];
        _blurView.dynamic = NO;
        [self.superview addSubview:_blurView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized)];
        tapGesture.numberOfTapsRequired = 1;
        [_blurView addGestureRecognizer:tapGesture];
        
        // Animate the views in.
        [self.superview bringSubviewToFront:_blurView];
        [self.superview bringSubviewToFront:self];
        _wasAnimated = animated;
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1;
                _blurView.alpha = 1;
            }];
        }
        else {
            self.alpha = 1;
            _blurView.alpha = 1;
        }
    }
}

- (void)hideAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 0;
            _blurView.alpha = 0;
        } completion:^(BOOL finished){
            self.hidden = YES;
            _blurView.hidden = YES;
        }]; }
    else {
        self.hidden = YES;
        _blurView.hidden = YES;
    }
}

- (void)addContentView:(UIView*)view title:(NSString*)title {
    view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.95];
    [_collectionTitles addObject:[title uppercaseString]];
    [_content addSubview:view];
    if (_collectionTitles.count == 1) {
        _titleLabel.text = [title uppercaseString];
    }
    _pageControl.numberOfPages = _collectionTitles.count;
}

- (void)addButton:(UIButton *)button {
    [_buttons addObject:button];
    [self addSubview:button];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentHeight = self.frame.size.height - 40;
    if (_pagingEnabled) {
        contentHeight -= 37;
    }
    if (_buttons || _buttons.count == 0) {
        contentHeight -= 50;
    }
    
    _titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    _content.frame = CGRectMake(0, 40, self.frame.size.width, contentHeight);
    _content.contentSize = CGSizeMake(self.frame.size.width * _collectionTitles.count, _content.frame.size.height);
    int position = 0;
    for (UIView *view in _content.subviews) {
        view.frame = CGRectMake(position * _content.frame.size.width, 0, _content.frame.size.width, _content.frame.size.height);
        position++;
    }
    
    if (_pagingEnabled) {
        _pageControl.frame = CGRectMake(0, self.frame.size.height - 87, self.frame.size.width, 37);
    }
    // _importButton.frame = CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50);
    
}

# pragma mark Scroll View Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    _pageControl.currentPage = page;
    _titleLabel.text = _collectionTitles[page];
}

- (void)tapRecognized {
    [self hideAnimated:_wasAnimated];
    if (_hidView) {
        _hidView();
    }
}

@end
