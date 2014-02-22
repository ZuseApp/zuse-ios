#import "ZS_StatementView.h"

@interface ZS_TouchLabel : UILabel
- (instancetype) initWithText: (NSString*)text font: (UIFont*)font;
@property (copy, nonatomic) void (^touched)();
@end

@implementation ZS_TouchLabel

- (instancetype) initWithText: (NSString*)text font: (UIFont*)font
{
    if (self = [super init])
    {
        self.font = font;
        self.text = text;
        self.textColor = [UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:1];
        self.highlightedTextColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.cornerRadius = self.font.pointSize * 0.5;
        self.userInteractionEnabled = YES;
    }
    return self;
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"code editor label touched"
                                                        object: self];
    if (self.touched)
    {
        self.touched(self);
    }
}
- (void) setText:(NSString *)text
{
    [super setText: text];
    [self sizeToFit];
}
- (void) sizeToFit
{
    [super sizeToFit];
    
    // add padding
    CGRect frame = self.frame;
    frame.size.width += self.font.pointSize;
    self.frame = frame;
}
- (void) setHighlighted:(BOOL)isHighlighted
{
    super.highlighted = isHighlighted;
    self.backgroundColor = isHighlighted ? [UIColor orangeColor] : [UIColor clearColor];
}
@end

@interface ZS_StatementView ()

// Appearance
@property (strong, nonatomic) UIFont* font;
@property (nonatomic) NSInteger bodyIndentation;

// State
@property (strong, nonatomic) NSMutableArray* header; // of UILabel
@property (strong, nonatomic) NSMutableArray* body; // of ZS_StatementView
@property (strong, nonatomic) UILabel* parameters;
@property (strong, nonatomic) NSMutableArray* name; // of UILabel
@property (nonatomic, getter = isCollapsed) BOOL collapsed;
@end

@implementation ZS_StatementView

- (instancetype) initWithJson: (NSMutableDictionary*) json
{
    if (self = [super init])
    {
        self.font = [UIFont boldSystemFontOfSize: 20];
        self.bodyIndentation = self.font.pointSize * 2;
        self.layer.cornerRadius = 5;
        self.json = json;
        
        self.name = [[NSMutableArray alloc]init];
        self.header = [[NSMutableArray alloc]init];
        self.body = [[NSMutableArray alloc]init];
        
        // Add double tap recognizer
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - Interface Methods

-(void)addNameLabelWithText:(NSString*)text
{
    UILabel* label = [[UILabel alloc]init];
    label.font = self.font;
    label.text = text.uppercaseString;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blueColor];
    label.highlightedTextColor = [UIColor whiteColor];
    [label sizeToFit];
    
    // Add to statement view
    [self.header addObject:label];
    [self.name addObject:label];
    [self addSubview:label];
}
- (void)addArgumentLabelWithText:(NSString*)text touchBlock:(void (^)(UILabel*))touchBlock
{
    ZS_TouchLabel* label = [[ZS_TouchLabel alloc]initWithText:text font:self.font];
    label.touched = touchBlock;
    
    // Add to statement view
    [self.header addObject:label];
    [self addSubview:label];
}
- (void) addSubStatementView: (ZS_StatementView*) subStatementView
{
    [self.body addObject: subStatementView];
    [self addSubview:subStatementView];
}
- (void) addParametersLabelWithText: (NSString*) text
{
    // Remove previous parametersLabel
    [self.name removeObject:self.parameters];
    [self.parameters removeFromSuperview];
    
    // Change parameters label text
    self.parameters.text = text;
    [self.parameters sizeToFit];
    
    // Add parameters label
    [self.name addObject:self.parameters];
    [self addSubview: self.parameters];
}
- (void) addNewStatementLabelWithTouchBlock: (void(^)(UILabel*)) touchBlock
{
    ZS_TouchLabel* label = [[ZS_TouchLabel alloc]initWithText: @"add new statement"
                                                               font: self.font];
    label.textColor = [UIColor lightGrayColor];
    label.touched = touchBlock;
    [self.body addObject:label];
    [self addSubview:label];    
}
- (void) setHighlighted:(BOOL)isHighlighted
{
    _highlighted = isHighlighted;
    
    // Highlight the name labels
    for (UILabel* label in self.name)
    {
        label.highlighted = isHighlighted;
    }
    // Hightlight background
    self.backgroundColor = isHighlighted ? [UIColor colorWithWhite: 0.8 alpha: 1] : [UIColor clearColor];
}
- (void) setTopLevelStatement:(BOOL)isTopLevelStatement
{
    _topLevelStatement = isTopLevelStatement;
    if (isTopLevelStatement)
    {
        for (UIGestureRecognizer* gr in self.gestureRecognizers)
        {
            [self removeGestureRecognizer: gr];
        }
        self.bodyIndentation = 2;
    }
}

# pragma mark UIView methods

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    if (self.body.count && sender.state == UIGestureRecognizerStateRecognized)
    {
        self.collapsed = !self.isCollapsed;
    }
}
- (void) layoutSubviews
{
    CGFloat x = 2;
    
    // Layout header
    for (UIView* subview in self.header)
    {
        CGRect frame = subview.frame;
        frame.origin.x = x;
        subview.frame = frame;
        x = CGRectGetMaxX(frame);
    }
    // Layout parameters
    CGFloat headerMaxY = CGRectGetMaxY(((UIView*)self.header.firstObject).frame);
    CGRect frame = self.parameters.frame;
    frame.origin = CGPointMake(2, headerMaxY);
    self.parameters.frame = frame;
    
    // Layout body
    CGFloat parametersLineMaxY = CGRectGetMaxY(self.parameters.frame);
    CGFloat y =  MAX(headerMaxY, parametersLineMaxY);
    for (UIView* subview in self.body)
    {
        [subview setNeedsLayout];
        CGRect frame = subview.frame;
        frame.origin.x = self.bodyIndentation;
        frame.origin.y = y;
        subview.frame = frame;
        y = CGRectGetMaxY(frame);
    }
    // resize this statement view to fit subviews
    frame = CGRectZero;
    for (UIView *view in self.subviews)
    {
        frame = CGRectUnion(frame, view.frame);
    }
    frame.origin = self.frame.origin;
    self.frame = frame;
    
    if ([self.superview isKindOfClass: [UIScrollView class]])
    {
        ((UIScrollView*)self.superview).contentSize = self.frame.size;
    }
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.topLevelStatement && !self.isHighlighted)
    {
        self.highlighted = YES;
        
        // Notify Code Editor Controller
        [[NSNotificationCenter defaultCenter] postNotificationName: @"statement view selected"
                                                            object: self];
    }
}

# pragma mark - Private Methods

- (void) setCollapsed:(BOOL)collapsed
{
    _collapsed = collapsed;
    if (collapsed)
    {
        // Add '+ ' in front of the statement name
        UILabel* firstHeaderLabel = (UILabel*)self.header.firstObject;
        firstHeaderLabel.text = [@"▸ " stringByAppendingString: firstHeaderLabel.text];
        [firstHeaderLabel sizeToFit];
        
        // Remove statement body
        [self.body makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else
    {
        // Add statement body
        for (UIView* view in self.body)
        {
            [self addSubview:view];
        }
        // Remove '+ ' in front of the statement name
        UILabel* firstHeaderLabel = (UILabel*)self.header.firstObject;
        firstHeaderLabel.text = [firstHeaderLabel.text substringFromIndex:@"▾ ".length];
        [firstHeaderLabel sizeToFit];
    }
    [self setNeedsLayout];
}
- (UILabel*) parameters
{
    if (!_parameters)
    {
        _parameters = [[UILabel alloc]init];
        _parameters.highlightedTextColor = [UIColor whiteColor];
        _parameters.font = [self.font fontWithSize:self.font.pointSize * 0.75];
        _parameters.textColor = [UIColor lightGrayColor];
        _parameters.numberOfLines = 2;
    }
    return _parameters;
}
@end
