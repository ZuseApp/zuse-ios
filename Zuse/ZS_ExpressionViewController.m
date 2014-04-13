#import "ZS_ExpressionViewController.h"
#import "ZS_ExpressionVariableChooserCollectionViewController.h"
#import "ZS_FunctionChooserCollectionViewController.h"
#import "ZS_JsonUtilities.h"
#import "ZSToolboxView.h"
#import <MTBlockAlertView/MTBlockAlertView.h>
#import "ZSTutorial.h"

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
    ZS_OperatorAnd = 12
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
        default: return nil;
    }
}
@interface ZS_ExpressionLabel : UILabel
@property (strong, nonatomic) NSObject* json;
@property (nonatomic) ZS_ExpressionLabel* parentNode;
@property (strong, nonatomic) NSMutableArray* nodes; // of ZS_ExpressionLabel
@property (strong, nonatomic) UIMenuController *menuController;

- (NSArray*) allLabels; // in order they appear from left to right including itself
- (NSArray*) allNodes;

- (void) setOperator: (ZS_Operator) operator;
- (void) setNumber: (NSNumber*) number;
- (void) setVariableName: (NSString*) name;
- (void) setString: (NSString*) str;
- (void) setFunction:(NSMutableDictionary*) fnJson;

- (BOOL) isOperator;
- (BOOL) isFunctionCall;
- (BOOL) isNumber;
@end

@implementation ZS_ExpressionLabel

- (instancetype) init
{
    if (self = [super init])
    {
        self.font = [UIFont zuseFontWithSize:25];
        self.textColor = [UIColor zuseExpressionEditorTintColor];
        self.highlightedTextColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.text = nil;
        self.layer.cornerRadius = self.font.pointSize * 0.2;
        self.userInteractionEnabled = YES;
        self.nodes = [[NSMutableArray alloc]init];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wasTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self  action:@selector(wasLongPressed:)];
        [self addGestureRecognizer:longRecognizer];
    }
    return self;
}
#pragma mark Interface

- (void) setJson: (NSObject *)json
{
    [self clean];
    
    // String
    if ([ZS_JsonUtilities isString: json])
    {
        _json = json;
        self.text = [(NSString*)json characterAtIndex:0] == '#' ? @"   " : (NSString*)json;
    }
    // Number
    else if ([ZS_JsonUtilities isNumber: json])
    {
        _json = json;
        self.text = ((NSNumber*)json).stringValue;
    }
    // Function
    else if ([ZS_JsonUtilities isFunctionCall:json])
    {
        _json = json;
        
        // Add parameter labels as child nodes
        NSMutableDictionary* parameters = ((NSDictionary*)json)[@"call"][@"parameters"];
        for (NSInteger i = 0; i < parameters.count; i++)
        {
            ZS_ExpressionLabel* paramNode = [[ZS_ExpressionLabel alloc] init];
            paramNode.json = ((NSDictionary*)json)[@"call"][@"parameters"][i];
            paramNode.parentNode = self;
            [self.nodes addObject: paramNode];
        }
        // Set function name
        NSString* functionName = ((NSDictionary*)json)[@"call"][@"method"];
        self.text = [ZS_JsonUtilities convertToFansySymbolFromJsonOperator: functionName];
    }
    // Variable name
    else if ([ZS_JsonUtilities isVariableName: json])
    {
        _json = json;
        self.text = ((NSDictionary*)json)[@"get"];
    }
    // Operator
    else if ([ZS_JsonUtilities isOperator: json])
    {
        _json = json;
        NSString* operator = ((NSDictionary*)json).allKeys[0];
        self.text = [ZS_JsonUtilities convertToFansySymbolFromJsonOperator: operator];
        
        // Left label
        ZS_ExpressionLabel* leftLabel = [[ZS_ExpressionLabel alloc]init];
        leftLabel.json = ((NSDictionary*)json)[operator][0];
        leftLabel.parentNode = self;
        [self.nodes addObject: leftLabel];
        
        // Right label
        ZS_ExpressionLabel* rightLabel = [[ZS_ExpressionLabel alloc]init];
        rightLabel.json = ((NSDictionary*)json)[operator][1];
        rightLabel.parentNode = self;
        [self.nodes addObject: rightLabel];
    }
    // Make changes in the parent's json
    if (self.parentNode)
    {
        // Parent is function call
        if (self.parentNode.isFunctionCall)
        {
            NSMutableDictionary* parentJson = (NSMutableDictionary*)self.parentNode.json;
            NSArray* parentParameters = parentJson[@"call"][@"parameters"];
            for (NSInteger i = 0; i < parentParameters.count; i++)
            {
                if (self.parentNode.nodes[i] == self)
                {
                    parentJson[@"call"][@"parameters"][i] = self.json;
                    break;
                }
            }
        }
        // Parent is Operator
        else if (self.parentNode.isOperator)
        {
            NSString* key = ((NSMutableDictionary*)self.parentNode.json).allKeys[0];
            
            // self is parent's left node
            if (self.parentNode.nodes[0] == self)
            {
                ((NSMutableDictionary*)self.parentNode.json)[key][0] = self.json;
            }
            // self is parent's right node
            else
            {
                ((NSMutableDictionary*)self.parentNode.json)[key][1] = self.json;
            }
        }
    }
}
- (void) setOperator:(ZS_Operator)operator
{
    // self is operator
    if (self.isOperator)
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
    else
    {
        NSMutableDictionary* json = [[NSMutableDictionary alloc]init];
        NSString* key = ZS_OperatorToString(operator);
        json[key] = [NSMutableArray arrayWithArray: @[self.json, @"#expression"]];
        self.json = json;
    }
}
- (void) setNumber: (NSNumber*) number
{
    if (!self.isOperator && !self.isFunctionCall)
    {
        self.json = number;
    }
}
- (void) setVariableName: (NSString*) name
{
    if (!self.isOperator && !self.isFunctionCall)
    {
        self.json = [NSMutableDictionary dictionaryWithDictionary:@{@"get": name}];
    }
}
- (void) setString: (NSString*) str
{
    if (!self.isOperator && !self.isFunctionCall)
    {
        self.json = str;
    }
}
- (void) setFunction:(NSMutableDictionary*) fnJson
{
    if (!self.isOperator && !self.isFunctionCall)
    {
        NSInteger parametersCount = ((NSMutableArray*)fnJson[@"call"][@"parameters"]).count;
        if (parametersCount == 1)
        {
            fnJson[@"call"][@"parameters"] = [NSMutableArray arrayWithArray: @[self.json]];
        }
        self.json = fnJson;
    }
}
- (NSArray*) allLabels
{
    NSMutableArray* labels = [[NSMutableArray alloc]init];
    
    // self is operator
    if (self.isOperator)
    {
        // Left parenthesys
        if (self.parentNode != nil)
        {
            UILabel* label = [[ZS_ExpressionLabel alloc]init];
            label.text = @"(";
            label.userInteractionEnabled = NO;
            [labels addObject: label];
        }
        
        // Operator
        [labels addObjectsFromArray: ((ZS_ExpressionLabel*)self.nodes[0]).allLabels];
        [labels addObject: self];
        [labels addObjectsFromArray: ((ZS_ExpressionLabel*)self.nodes[1]).allLabels];
        
        // Right parenthesys
        if (self.parentNode != nil)
        {
            UILabel* label = [[ZS_ExpressionLabel alloc]init];
            label = [[ZS_ExpressionLabel alloc]init];
            label.text = @")";
            label.userInteractionEnabled = NO;
            [labels addObject: label];
        }
    }
    // self is function call
    else if (self.isFunctionCall)
    {
        // add function name label
        [labels addObject: self];
        
        // Left parenthesys
        if (self.nodes.count > 1)
        {
            UILabel* left= [[ZS_ExpressionLabel alloc]init];
            left.text = @"(";
            left.userInteractionEnabled = NO;
            [labels addObject: left];
        }
        // add parameters
        for (NSInteger i = 0; i < self.nodes.count; i++)
        {
            // parameter
            [labels addObjectsFromArray: ((ZS_ExpressionLabel*)self.nodes[i]).allLabels];
            
            // Comma
            if (i < self.nodes.count - 1)
            {
                UILabel* comma= [[ZS_ExpressionLabel alloc]init];
                comma.text = @", ";
                comma.userInteractionEnabled = NO;
                [labels addObject: comma];
            }
        }
        // Right parenthesys
        if (self.nodes.count > 1)
        {
            UILabel* right = [[ZS_ExpressionLabel alloc]init];
            right.text = @")";
            right.userInteractionEnabled = NO;
            [labels addObject: right];
        }
    }
    else
    {
        [labels addObject:self];
    }
    return labels;
}
- (NSArray*) allNodes
{
    NSMutableArray* nodes = [[NSMutableArray alloc]init];
    
    // self is operator
    if (self.isOperator)
    {
        [nodes addObjectsFromArray: ((ZS_ExpressionLabel*)self.nodes[0]).allNodes];
        [nodes addObject: self];
        [nodes addObjectsFromArray: ((ZS_ExpressionLabel*)self.nodes[1]).allNodes];
    }
    // self is function call
    else if (self.isFunctionCall)
    {
        [nodes addObject:self];
        for (ZS_ExpressionLabel* node in self.nodes)
        {
            [nodes addObjectsFromArray: node.allNodes];
        }
    }
    else
    {
        [nodes addObject:self];
    }
    return nodes;
}
- (BOOL) isOperator
{
    return [ZS_JsonUtilities isOperator: self.json];
}
- (BOOL) isNumber
{
    return [ZS_JsonUtilities isNumber:self.json];
}
- (BOOL) isFunctionCall
{
    return [ZS_JsonUtilities isFunctionCall: self.json];
}
#pragma mark - Private Methods

- (void) clean
{
    [self.nodes removeAllObjects];
    self.text = @"   ";
    _json = @"#expression";
}
#pragma mark UIView

- (void)wasTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"any expression label touched"
                                                        object: self];
    [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
}

- (void)wasLongPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"any expression label touched"
                                                        object: self];
    self.menuController = [UIMenuController sharedMenuController];
    [self becomeFirstResponder];
    [self.menuController setTargetRect:self.bounds inView:self];
    [self.menuController setMenuVisible:YES animated:YES];
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
    self.layer.backgroundColor = isHighlighted ? [UIColor zuseExpressionEditorTintColor].CGColor:[UIColor clearColor].CGColor;
}
@end

@interface ZS_ExpressionViewController ()
@property (weak, nonatomic) IBOutlet UIView *expressionView;
@property (strong, nonatomic) ZS_ExpressionLabel* headNode;
@property (weak, nonatomic) ZS_ExpressionLabel* selectedNode;
@property (strong, nonatomic) NSString* numberBuffer;
@property (strong, nonatomic) ZS_ExpressionVariableChooserCollectionViewController* variableChooserController;
@property (strong, nonatomic) ZS_FunctionChooserCollectionViewController* functionChooserController;
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
//	self.expressionView.layer.cornerRadius = 5;
    self.numberBuffer = @"";
    self.headNode = [[ZS_ExpressionLabel alloc] init];
    self.headNode.json = self.json;
    self.selectedNode = self.headNode;
    [self reloadExpression];
}
- (void) notificationReceived: (NSNotification*) notification
{
    if ([notification.name isEqualToString:@"any expression label touched"])
    {
        self.selectedNode = notification.object;
    }
}
- (void) reloadExpression
{
    // Reload
    for (UIView* subview in self.expressionView.subviews)
    {
        [subview removeFromSuperview];
    }
    for (UIView* node in self.headNode.allLabels)
    {
        [self.expressionView addSubview:node];
    }
    // Layout
    CGFloat padding = 8;
    
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
    if ( !self.selectedNode.isOperator && !self.selectedNode.isFunctionCall)
    {
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString* numberBuffer = [self.numberBuffer stringByAppendingString: sender.titleLabel.text];
        NSNumber * number = [formatter numberFromString: numberBuffer];
        if (number)
        {
            self.numberBuffer = numberBuffer;
            [self.selectedNode setNumber: number];
            [self reloadExpression];
        }
    }
}
- (IBAction)deleteButtonTapped
{
    [self.selectedNode clean];
    self.numberBuffer = @"";
    [self reloadExpression];
}
- (IBAction)operatorButtonTapped:(UIButton *)sender
{
    [self.selectedNode setOperator: sender.tag];
    
    if ([((ZS_ExpressionLabel*)self.selectedNode.nodes[0]).text characterAtIndex:0] == ' ')
    {
        self.selectedNode = self.selectedNode.nodes[0];
    }
    else
    {
        self.selectedNode = self.selectedNode.nodes[1];
    }
    [self reloadExpression];
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
        [self reloadExpression];
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
         
         if (!self.selectedNode.isFunctionCall && !self.selectedNode.isOperator)
         {
             NSString* str = [alertView textFieldAtIndex:0].text;
             if (![str isEqualToString:@""])
             {
                 [self.selectedNode setString: str];
                 [self reloadExpression];
             }
         }
     }
                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}
- (IBAction)functionsButtonTapped
{
    if (!self.selectedNode.isFunctionCall && !self.selectedNode.isOperator)
    {
        ZSToolboxView* functionToolboxView =
        [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
        
        ZS_FunctionChooserCollectionViewController* functionChooserController =
        [[ZS_FunctionChooserCollectionViewController alloc]init];
        
        functionChooserController.toolboxView = functionToolboxView;
        functionChooserController.didFinish = ^(NSMutableDictionary* function)
        {
            [self.selectedNode setFunction: function];
            self.selectedNode = self.selectedNode.nodes[0];
            [self reloadExpression];
        };
        self.functionChooserController = functionChooserController;
        
        [functionToolboxView setPagingEnabled:NO];
        [functionToolboxView addContentView: functionChooserController.collectionView
                                      title: @"FUNCTION CHOOSER"];
        [self.view addSubview: functionToolboxView];
        
        [functionToolboxView showAnimated:YES];
    }
}
- (IBAction)changeSignButtonTapped
{
    if (self.selectedNode.isNumber)
    {
        NSNumber* number = (NSNumber*)self.selectedNode.json;
        number = [NSNumber numberWithFloat: number.floatValue * -1];
        [self.selectedNode setNumber: number];
        [self reloadExpression];
    }
}

#pragma mark UIMenuController
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)delete:(id)sender {
    [self deleteButtonTapped];
}
@end
