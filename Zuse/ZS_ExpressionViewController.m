#import "ZS_ExpressionViewController.h"
#import "ZS_ExpressionVariableChooserCollectionViewController.h"
#import "ZS_JsonUtilities.h"
#import "ZSToolboxView.h"
#import <MTBlockAlertView/MTBlockAlertView.h>

typedef NS_ENUM(NSInteger, ZS_Operator)
{
    ZS_OperatorPlus = 0,
    ZS_OperatorMinus = 1,
    ZS_OperatorMultiply = 2,
    ZS_OperatorDivide = 3,
    ZS_OperatorModulus = 4,
    ZS_OperatorGreaterThan = 5,
    ZS_OperatorLessThan = 6,
    ZS_OperatorGreaterThanOrEqual = 7,
    ZS_OperatorLessThanOrEqual = 8,
    ZS_OperatorEqual = 9,
    ZS_OperatorNotEqual = 10,
    ZS_OperatorOr = 11,
    ZS_OperatorAnd = 12,
    ZS_OperatorSQRT = 13
};
NSString* ZS_OperatorToString(ZS_Operator operator)
{
    switch (operator)
    {
        case ZS_OperatorPlus: return @"+";
        case ZS_OperatorMinus: return @"-";
        case ZS_OperatorMultiply: return @"*";
        case ZS_OperatorDivide: return @"/";
        case ZS_OperatorModulus: return @"%";
        case ZS_OperatorGreaterThan: return @">";
        case ZS_OperatorLessThan: return @"<";
        case ZS_OperatorGreaterThanOrEqual: return @">=";
        case ZS_OperatorLessThanOrEqual: return @"<=";
        case ZS_OperatorEqual: return @"==";
        case ZS_OperatorNotEqual: return @"!=";
        case ZS_OperatorAnd: return @"and";
        case ZS_OperatorOr: return @"or";
        case ZS_OperatorSQRT: return @"sqrt";
        default: return nil;
    }
}
@interface ZS_ExpressionLabel : UILabel

@property (strong, nonatomic) NSObject* json;
@property (nonatomic, readonly) ZS_ExpressionLabel* parentNode;
@property (strong, nonatomic, readonly) ZS_ExpressionLabel* leftNode;
@property (strong, nonatomic, readonly) ZS_ExpressionLabel* rightNode;

- (void) clean;
- (NSArray*) allViews; // in order they appear from left to right including itself
- (NSArray*) allNodes;
- (void) setOperator: (ZS_Operator) operator;
- (void) setNumber: (NSNumber*) number;
- (void) setVariableName: (NSString*) name;
- (BOOL) isLeaf;
@end

@interface ZS_ExpressionLabel ()
@property (nonatomic, readwrite) ZS_ExpressionLabel* parentNode;
@property (strong, nonatomic, readwrite) ZS_ExpressionLabel* leftNode;
@property (strong, nonatomic, readwrite) ZS_ExpressionLabel* rightNode;
@property (strong, nonatomic) UIColor* selectedBackgroundColor;
@property (strong, nonatomic) UIColor* unselectedBackgroundColor;
@end

@implementation ZS_ExpressionLabel

- (instancetype) init
{
    if (self = [super init])
    {
        self.font = [UIFont boldSystemFontOfSize: 20];
        self.textColor = [UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:1];
        self.highlightedTextColor = [UIColor whiteColor];
        self.text = nil;
        self.layer.cornerRadius = self.font.pointSize * 0.2;
        self.userInteractionEnabled = YES;
    }
    return self;
}
#pragma mark Interface

- (void) setJson: (NSObject *)json
{
    _json = json;
    
    if ([json isKindOfClass: [NSDictionary class]])
    {
        NSString* key = ((NSDictionary*)json).allKeys[0];
        
        // Variable name
        if ([key isEqualToString:@"get"])
        {
            self.text = ((NSDictionary*)json)[@"get"];
        }
        // Operator
        else
        {
            self.text = [ZS_JsonUtilities convertToFansySymbolFromJsonOperator: key];
            [self addLeaves];
            self.leftNode.json = ((NSDictionary*)json)[key][0];
            self.rightNode.json = ((NSDictionary*)json)[key][1];
        }
    }
    // String
    else if ([json isKindOfClass: [NSString class]])
    {
        NSString* text = (NSString*)json;
        self.text = [text characterAtIndex:0] == '#' ? @"   " : text;
    }
    // Number
    else if ([json isKindOfClass: [NSNumber class]])
    {
        self.text = ((NSNumber*)json).stringValue;
    }
    // make changes in the parent's json
    NSMutableDictionary* parentJson = (NSMutableDictionary*)self.parentNode.json;
    NSString* parentKey = parentJson.allKeys[0];
    if (self.parentNode.leftNode == self)
    {
        parentJson[parentKey][0] = self.json;
    }
    else
    {
        parentJson[parentKey][1] = self.json;
    }
}
- (void) setOperator:(ZS_Operator)operator
{
    if (self.isLeaf)
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc]init];
        NSString* key = ZS_OperatorToString(operator);
        json[key] = [NSMutableArray arrayWithArray: @[self.json, @"#expression"]];
        self.json = json;
    }
    else
    {
        // get value
        NSMutableDictionary* json = (NSMutableDictionary*)self.json;
        NSString* oldKey = json.allKeys[0];
        NSObject* value = json[oldKey];
        
        // replace json with a dictionary with the new key / value
        NSString* newKey = ZS_OperatorToString(operator);
        self.json = [NSMutableDictionary dictionaryWithDictionary:@{newKey : value}];
        
        // set text of the label
        self.text = [ZS_JsonUtilities convertToFansySymbolFromJsonOperator: newKey];
    }
}
- (void) setNumber: (NSNumber*) number
{
    if (self.isLeaf)
    {
        self.json = number;
    }
}
- (void) setVariableName: (NSString*) name
{
    if (self.isLeaf)
    {
        self.json = [NSMutableDictionary dictionaryWithDictionary:@{@"get": name}];
    }
}
- (NSArray*) allViews
{
    NSMutableArray* views = [[NSMutableArray alloc]init];
    
    if (self.isLeaf)
    {
        [views addObject:self];
    }
    else
    {
        // Left parenthesys
        if (!self.isHeadNode)
        {
            UILabel* label = [[ZS_ExpressionLabel alloc]init];
            label.text = @"(";
            label.userInteractionEnabled = NO;
            [views addObject: label];
        }
        
        // Operator
        [views addObjectsFromArray: self.leftNode.allViews];
        [views addObject: self];
        [views addObjectsFromArray: self.rightNode.allViews];
        
        // Right parenthesys
        if (!self.isHeadNode)
        {
            UILabel* label = [[ZS_ExpressionLabel alloc]init];
            label = [[ZS_ExpressionLabel alloc]init];
            label.text = @")";
            label.userInteractionEnabled = NO;
            [views addObject: label];
        }
    }
    return views;
}
- (NSArray*) allNodes
{
    NSMutableArray* nodes = [[NSMutableArray alloc]init];
    
    if (self.isLeaf)
    {
        [nodes addObject:self];
    }
    else
    {
        [nodes addObjectsFromArray: self.leftNode.allNodes];
        [nodes addObject: self];
        [nodes addObjectsFromArray: self.rightNode.allNodes];
    }
    return nodes;
}
- (BOOL) isLeaf
{
    return !(self.leftNode || self.rightNode);
}
- (void) addLeaves
{
    if (self.isLeaf)
    {
        self.leftNode = [[ZS_ExpressionLabel alloc] init];
        self.leftNode.parentNode = self;
        self.rightNode = [[ZS_ExpressionLabel alloc] init];
        self.rightNode.parentNode = self;
    }
}
- (void) clean
{
    self.leftNode = nil;
    self.rightNode = nil;
    self.json = @"#expression";
}
#pragma mark Private

- (BOOL) isHeadNode
{
    return self.parentNode == nil;
}
#pragma mark UIView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"any expression label touched"
                                                        object: self];
}
#pragma mark UILabel

- (void) setText:(NSString*) text
{
    super.text = text;
    [self sizeToFit];
}
- (void) setHighlighted: (BOOL)isHighlighted
{
    super.highlighted = isHighlighted;
    self.layer.backgroundColor = isHighlighted ? [UIColor orangeColor].CGColor:[UIColor clearColor].CGColor;
}
@end

@interface ZS_ExpressionViewController ()
@property (weak, nonatomic) IBOutlet UIView *expressionView;
@property (strong, nonatomic) ZS_ExpressionLabel* headNode;
@property (weak, nonatomic) ZS_ExpressionLabel* selectedNode;
@property (strong, nonatomic) NSString* numberBuffer;
@property (strong, nonatomic) ZS_ExpressionVariableChooserCollectionViewController* variableChooserController;
@end

@implementation ZS_ExpressionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register at notification center
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notificationReceived:)
                                                 name: nil
                                               object: nil];
    self.expressionView.backgroundColor = [UIColor whiteColor];
    self.expressionView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.expressionView.layer.borderWidth = 1;
	self.expressionView.layer.cornerRadius = 5;
    self.numberBuffer = @"";
    self.headNode = [[ZS_ExpressionLabel alloc] init];
    self.headNode.json = self.json;
    self.selectedNode = self.headNode;
    [self reloadExpressionViewSubviews];
}
- (void) notificationReceived: (NSNotification*) notification
{
    if ([notification.name isEqualToString:@"any expression label touched"])
    {
        self.selectedNode = notification.object;
    }
}
- (void) reloadExpressionViewSubviews
{
    // Reload
    for (UIView* subview in self.expressionView.subviews)
    {
        [subview removeFromSuperview];
    }
    for (UIView* node in self.headNode.allViews)
    {
        [self.expressionView addSubview:node];
    }
    // Layout
    CGFloat padding = 1;
    
    CGFloat x = padding;
    CGFloat y = padding;
    for (UIView* view in self.expressionView.subviews)
    {
        CGRect frame = view.frame;
        CGFloat totalWidth = x + frame.size.width;
        if (totalWidth > self.expressionView.frame.size.width)
        {
            x = padding;
            y = y + padding + frame.size.height;
        }
        frame.origin = CGPointMake(x, y);
        view.frame = frame;
        x = CGRectGetMaxX(view.frame);
    }
}
- (void) setSelectedNode: (ZS_ExpressionLabel*) selectedNode
{
    if (_selectedNode != selectedNode)
    {
        _selectedNode.highlighted = NO;
        _selectedNode = selectedNode;
        _selectedNode.highlighted = YES;
        self.numberBuffer = @"";
    }
}
#pragma mark IBActions

- (IBAction)digitButtonTapped:(UIButton *)sender
{
    if (self.selectedNode.isLeaf)
    {
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString* numberBuffer = [self.numberBuffer stringByAppendingString: sender.titleLabel.text];
        NSNumber * number = [formatter numberFromString: numberBuffer];
        if (number)
        {
            self.numberBuffer = numberBuffer;
            [self.selectedNode setNumber: number];
            [self reloadExpressionViewSubviews];
        }
    }
}
- (IBAction)deleteButtonTapped
{
    [self.selectedNode clean];
    self.numberBuffer = @"";
    [self reloadExpressionViewSubviews];
}
- (IBAction)operatorButtonTapped:(UIButton *)sender
{
    if (self.selectedNode.isLeaf)
    {
        [self.selectedNode setOperator: sender.tag];

        if ([self.selectedNode.leftNode.text characterAtIndex:0] == ' ')
        {
            self.selectedNode = self.selectedNode.leftNode;
        }
        else
        {
            self.selectedNode = self.selectedNode.rightNode;
        }
    }
    else
    {
        [self.selectedNode setOperator: sender.tag];
    }
    [self reloadExpressionViewSubviews];
}
- (IBAction)doneButtonTapped
{
    if (self.didFinish)
    {
        self.json = self.headNode.json;
        self.didFinish(self.json);
    }
}
- (IBAction)cancelButtonTapped
{
    if (self.didFinish)
    {
        self.didFinish(nil);
    }
}
- (IBAction)moveToPreviousNodeButtonTapped
{
    NSArray* nodes = self.headNode.allNodes;
    NSInteger i = [nodes indexOfObject:self.selectedNode];
    self.selectedNode =  (i == 0) ? nodes[nodes.count-1] : nodes[i-1];
}
- (IBAction)moveToNextNodeButtonTapped
{
    NSArray* nodes = self.headNode.allNodes;
    NSInteger i = [nodes indexOfObject:self.selectedNode];
    self.selectedNode =  (i == nodes.count-1) ? nodes[0] : nodes[i+1];
}
- (IBAction)varButtonTapped
{
    ZSToolboxView* variableToolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
    
    ZS_ExpressionVariableChooserCollectionViewController *variableChooserController =
    [[ZS_ExpressionVariableChooserCollectionViewController alloc]init];
    
    variableChooserController.variables = self.variableNames;
    variableChooserController.toolboxView = variableToolboxView;
    variableChooserController.didFinish = ^(NSString* variableName)
    {
        [self.selectedNode setVariableName: variableName];
        self.numberBuffer = @"";
        [self reloadExpressionViewSubviews];
    };
    self.variableChooserController = variableChooserController;
    
    [variableToolboxView setPagingEnabled:NO];
    [variableToolboxView addContentView: variableChooserController.collectionView
                                  title: @"VARIABLE CHOOSER"];
    [self.view addSubview: variableToolboxView];
    
    [variableToolboxView showAnimated:YES];
}
- (IBAction)strButtonTapped
{
    MTBlockAlertView *alertView =
    [[MTBlockAlertView alloc] initWithTitle: @"Create A String"
                                    message: @"Please, enter a string"
                          completionHanlder: ^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (self.didFinish)
         {
             NSString* str = [alertView textFieldAtIndex:0].text;
             self.didFinish([str isEqual:@""] ? nil : str);
         }
     }
                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}
@end
