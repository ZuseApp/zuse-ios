#import "ZS_StatementView.h"
#import <QuartzCore/QuartzCore.h>
#import "ZSTutorial.h"
#import "ZSColor.h"
#import <FontAwesomeKit/FAKIonIcons.h>

CGFloat const LabelPadding = 10.0f;

@interface ZS_TouchLabel : UILabel
- (instancetype) initWithText: (NSString*)text font: (UIFont*)font;
@property (copy, nonatomic) void (^hasBeenTouched)();
@end

@implementation ZS_TouchLabel

- (instancetype) initWithText: (NSString*)text font: (UIFont*)font
{
    if (self = [super init])
    {
        self.font = font;
        self.text = text;
        [self sizeToFit];
        
        // add padding
        CGRect frame = self.frame;
        frame.size.width += self.font.pointSize / 2;
        frame.size.height += LabelPadding - 4;
        frame.origin.y += 4;
        self.frame = frame;
        
        self.textColor = [UIColor zuseEditorTextColor];
        self.shadowColor = [UIColor zuseEditorTextShadowColor];
        self.shadowOffset = CGSizeMake(0, 1);
//        self.highlightedTextColor = [UIColor whiteColor];
//        self.backgroundColor = [UIColor zuseBackgroundGrey];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wasTapped:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)wasTapped:(id)sender
{
    self.highlighted = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"code editor label touched"
                                                        object: self];
    if (self.hasBeenTouched)
    {
        self.hasBeenTouched(self);
    }
    [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
}
//- (void) setText:(NSString *)text
//{
//    [super setText: text];
//    [self sizeToFit];
//}
//- (void) sizeToFit
//{
//    [super sizeToFit];
//    
//    // add padding
//    CGRect frame = self.frame;
//    frame.size.width += self.font.pointSize;
//    self.frame = frame;
//    
//}
//- (void) setHighlighted:(BOOL)isHighlighted
//{
//    super.highlighted = isHighlighted;
////    self.layer.backgroundColor = isHighlighted ? [UIColor orangeColor].CGColor : [UIColor clearColor].CGColor;
//}
@end
//
//
//
//
//
//
//@interface ZSNameLabel : UILabel
//
//@property (nonatomic, assign) UIEdgeInsets edgeInsets;
//
//@end
//
//@implementation ZSNameLabel
//
//- (id)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self sharedInit];
//    }
//    return self;
//}
//
//- (id)init {
//    self = [super init];
//    if (self) {
//        [self sharedInit];
//    }
//    return self;
//}
//
//- (void)sharedInit {
//    self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//}
//
//- (void)sizeToFit {
//    [super sizeToFit];
//    CGRect frame = self.frame;
//    frame.size.height += self.edgeInsets.bottom + self.edgeInsets.top;
//    frame.size.width += self.edgeInsets.left + self.edgeInsets.right;
//    self.frame = frame;
//}
//
//- (void)drawTextInRect:(CGRect)rect {
//    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
//}
//
//@end







@interface ZS_StatementView ()

// Appearance
@property (strong, nonatomic) UIFont* font;
@property (nonatomic) NSInteger bodyIndentation;

// State
@property (strong, nonatomic) NSMutableArray* header; // of UILabel
@property (strong, nonatomic) NSMutableArray* body; // of ZS_StatementView
@property (strong, nonatomic) UILabel* parameters;
@property (strong, nonatomic) NSMutableArray* name; // these will be highlighted when this statement is touched
@property (nonatomic, getter = isCollapsed) BOOL collapsed;
@end

@implementation ZS_StatementView

- (instancetype) initWithJson: (NSMutableDictionary*) json
{
    if (self = [super init])
    {
        self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        self.bodyIndentation = self.font.pointSize * 1.5;
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 0.5;
        self.json = json;

        self.backgroundColor = [ZSColor colorForDSLItem:json.allKeys.firstObject];

        self.layer.borderColor = [ZSColor darkenColor:self.backgroundColor withValue:0.1].CGColor;

        self.name = [[NSMutableArray alloc]init];
        self.header = [[NSMutableArray alloc]init];
        self.body = [[NSMutableArray alloc]init];
        
        // Add double tap recognizer
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        tapGesture.numberOfTapsRequired = 2;
        tapGesture.delegate = self;
        [self addGestureRecognizer: tapGesture];
        
        // Add long press recognizer
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        [self addGestureRecognizer: longPress];

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wasTapped:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    ZSTutorial *tutorial = [ZSTutorial sharedTutorial];
    if (!tutorial.active || [tutorial.allowedGestures containsObject:gestureRecognizer.class]) {
        return YES;
    }
    return NO;
}

#pragma mark - Interface Methods

-(void)addNameLabelWithText:(NSString*)text
{
//    ZSNameLabel* label = [[ZSNameLabel alloc]init];
//    label.font = self.font;
//    label.text = text;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.textColor = [UIColor zuseEditorTextColor];
//    label.shadowColor = [UIColor zuseEditorTextShadowColor];
//    label.shadowOffset = CGSizeMake(0, 1);
//    label.highlightedTextColor = [UIColor whiteColor];
//    [label sizeToFit];
//    CGRect frame = label.frame;
//    frame.size.height += LabelPadding;
//    frame.origin.x += 20;
//    label.frame = frame;
    
    UILabel* label = [[UILabel alloc]init];
    label.font = self.font;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor zuseEditorTextColor];
    label.highlightedTextColor = [UIColor whiteColor];
    [label sizeToFit];
    
    CGRect frame = label.frame;
    frame.origin.y += 7;
    label.frame = frame;
    
    // Add to statement view
    [self.header addObject:label];
    [self.name addObject:label];
    [self addSubview:label];
}
- (void)addArgumentLabelWithText:(NSString*)text touchBlock:(void (^)(UILabel*))touchBlock
{
    ZS_TouchLabel* label = [[ZS_TouchLabel alloc]initWithText:text font:self.font];
    label.hasBeenTouched = touchBlock;

    label.backgroundColor = [ZSColor darkenColor:self.backgroundColor withValue:0.1];
    if ([text hasPrefix:@"#"]) {
        label.textColor = [UIColor darkGrayColor];
        label.text = [text substringFromIndex:1];
    }
    
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
    ZS_TouchLabel* label = [[ZS_TouchLabel alloc]initWithText: @"         +          "
                                                               font: self.font];

    label.attributedText = [FAKIonIcons ios7PlusEmptyIconWithSize:label.font.pointSize * 1.2].attributedString;
    CGRect frame = label.frame;
    frame.size.height *= 1.2;
    label.frame = frame;
    label.textColor = [UIColor zuseEditorTextColor];
    label.shadowColor = [UIColor zuseEditorTextShadowColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [ZSColor darkenColor:self.backgroundColor withValue:0.1];
    label.layer.borderColor = [ZSColor darkenColor:label.backgroundColor withValue:0.01].CGColor;
    label.layer.borderWidth = 0.5;
    label.hasBeenTouched = touchBlock;
    [self.body addObject:label];
    [self addSubview:label];    
}
- (void) setHighlighted:(BOOL)isHighlighted
{
    _highlighted = isHighlighted;
    
//      // Highlight the name labels
//    for (UILabel* label in self.name)
//    {
//        label.highlighted = isHighlighted;
//    }
    // Hightlight background
    UIColor *backgroundColor = [ZSColor colorForDSLItem:self.json.allKeys.firstObject];
    if (isHighlighted) {
        self.backgroundColor = [ZSColor darkenColor:backgroundColor withValue:0.05];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor blackColor].CGColor;
    } else {
        self.backgroundColor = backgroundColor;
        self.layer.borderWidth = 0;
    }
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
        self.bodyIndentation = 0;
    }
}
- (void) layoutStatementSubviews
{
    [self layoutRecursive];
}

- (void)layoutRecursive
{
    CGFloat parameterPadding = 5;
    
    // Statement offset from left edge.
    CGFloat x = 8;
    
    // Layout header
    for (UIView* subview in self.header)
    {
        CGRect frame = subview.frame;
        
        // If the view is a parameter offset it so that it doesn't touch the statement text.
        frame.origin.x = ([subview isKindOfClass:ZS_TouchLabel.class]) ? x + parameterPadding : x;
        subview.frame = frame;
        x = CGRectGetMaxX(frame);
        
        if ([subview isKindOfClass:ZS_TouchLabel.class])
        {
            x += parameterPadding;
        }
    }
    
    // Layout parameters
    CGFloat headerMaxY = CGRectGetMaxY(((UIView*)self.header.firstObject).frame);
    CGRect frame = self.parameters.frame;
    frame.origin = CGPointMake(9, headerMaxY + 5);
    self.parameters.frame = frame;
    
    // Layout body
    CGFloat parametersLineMaxY = CGRectGetMaxY(self.parameters.frame) + parameterPadding;
    CGFloat y =  MAX(headerMaxY, parametersLineMaxY);
    BOOL isFirstIteration = YES;
    for (UIView* subview in self.body)
    {
        if ([subview isKindOfClass:[ZS_StatementView class]])
        {
            ZS_StatementView* statementView = (ZS_StatementView*)subview;
            [statementView layoutRecursive];
        }
        CGRect frame = subview.frame;
        frame.origin.x = self.bodyIndentation;
        frame.origin.y = y + (isFirstIteration ? 0 : 1);
        subview.frame = frame;
        y = CGRectGetMaxY(frame);
        isFirstIteration = NO;
    }
    
    // resize this statement view to fit subviews
    frame = CGRectZero;
    for (UIView *view in self.subviews)
    {
        frame = CGRectUnion(frame, view.frame);
    }
    
    //    for (UIView *subview in self.body) {
    //        CGRect subFrame = subview.frame;
    //        subFrame.size.width = frame.size.width;
    //        subview.frame = subFrame;
    //    }
    //
    //    frame.origin = self.frame.origin;
    //    frame.size.width += 20;
    
    // Add right and bottom padding.
    frame.size.height += parameterPadding;
    frame.size.width += parameterPadding;
    
    self.frame = frame;
    
//    if (self.body.count != 0) {
//        CGFloat maxWidth = frame.size.width - self.bodyIndentation;
//        
//        for (UIView *subview in self.body) {
//            CGFloat currentViewWidth = subview.frame.size.width;
//            if (currentViewWidth > maxWidth) {
//                maxWidth += currentViewWidth;
//            }
//        }
//        
//        for (UIView *subview in self.body) {
//            CGRect subFrame = subview.frame;
//            subFrame.size.width = maxWidth;
//            subview.frame = subFrame;
//        }
//    }
    
    // Remove the border from the hidden start method.
    if (self.isTopLevelStatement)
    {
        self.layer.borderWidth = 0;
    }
}

# pragma mark UIView methods

- (void)wasTapped:(id)sender
{
    if (!self.topLevelStatement && !self.isHighlighted)
    {
        self.highlighted = YES;

        // Notify Code Editor Controller
        [[NSNotificationCenter defaultCenter] postNotificationName: @"statement view selected"
                                                            object: self];
        [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
        [self.delegate hideMenuController];
    }
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

# pragma mark - Gesture handlers

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    if (self.body.count && sender.state == UIGestureRecognizerStateRecognized)
    {
        self.collapsed = !self.isCollapsed;
    }
}
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // Notify Code Editor Controller
        [[NSNotificationCenter defaultCenter] postNotificationName: @"statement view selected"
                                                            object: self];
        [self.delegate statementViewLongPressed: self];
    }
}
# pragma mark - Private methods

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
        firstHeaderLabel.text = [firstHeaderLabel.text substringFromIndex:@"▸ ".length];
        [firstHeaderLabel sizeToFit];
    }
    [self.topLevelStatementView layoutStatementSubviews];
}
- (ZS_StatementView*) topLevelStatementView
{
    return self.isTopLevelStatement ? self : ((ZS_StatementView*)self.superview).topLevelStatementView;
}
- (UILabel*) parameters
{
    if (!_parameters)
    {
        _parameters = [[UILabel alloc]init];
        _parameters.backgroundColor = [UIColor clearColor];
        _parameters.highlightedTextColor = [UIColor whiteColor];
        _parameters.font = [self.font fontWithSize:self.font.pointSize * 0.7];
        _parameters.textColor = [UIColor zuseBackgroundGrey];
        _parameters.numberOfLines = 2;
    }
    return _parameters;
}
@end
