#import <MTBlockAlertView/MTBlockAlertView.h>

#import "ZS_CodeEditorViewController.h"
#import "ZS_JsonUtilities.h"
#import "ZSZuseDSL.h"

#import "ZS_ExpressionViewController.h"
#import "ZS_JsonViewController.h"

#import "ZSCodePropertyScope.h"
#import "ZSToolboxView.h"
#import "ZS_VariableChooserCollectionViewController.h"
#import "ZS_StatementChooserCollectionViewController.h"
#import "ZS_EventChooserCollectionViewController.h"

#import "ZSTutorial.h"

@interface ZS_CodeEditorViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) UILabel* selectedLabel;
@property (weak, nonatomic) ZS_StatementView* selectedStatementView;
@property (strong, nonatomic) ZS_VariableChooserCollectionViewController* variableChooserController;
@property (strong, nonatomic) ZS_StatementChooserCollectionViewController* statementChooserController;
@property (strong, nonatomic) ZS_EventChooserCollectionViewController* eventChooserController;
@property (strong, nonatomic) NSMutableDictionary* statementCopyBuffer; // for menu
@end

@implementation ZS_CodeEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Register at notification center
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notificationReceived:)
                                                 name: nil
                                               object: nil];
    // Create object statement
    [self reloadFromJson];
}

- (void) reloadFromJson
{
    ZS_StatementView* objectStatementView =
    [self objectStatementViewFromJson: self.json
       beforeAddingSubstatementsBlock: ^(ZS_StatementView *statementView)
    {
           NSSet *initialProperties = [NSSet setWithArray:[self.json[@"properties"] allKeys]];
        
           statementView.propertyScope = [ZSCodePropertyScope scopeWithCode: self.json[@"code"]
                                                          initialProperties: initialProperties];
    }];
 
    // Clean scroll view
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Adjust the content size of the scroll view
    self.scrollView.contentSize = objectStatementView.bounds.size;
    
    // Add object view to scrollView
    [self.scrollView addSubview:objectStatementView];
}

- (void) notificationReceived: (NSNotification*) notification
{
    if ([notification.name isEqualToString: @"statement view selected"])
    {
        self.selectedStatementView.highlighted = NO;
        self.selectedLabel.highlighted = NO;
        self.selectedLabel = nil;
        self.selectedStatementView = notification.object;
    }
    if ([notification.name isEqualToString: @"code editor label touched"])
    {
        self.selectedStatementView.highlighted = NO;
        self.selectedStatementView = nil;
        self.selectedLabel.highlighted = NO;
        self.selectedLabel = notification.object;
    }
}
# pragma mark - json to Statement Views

- (void) addToView: (ZS_StatementView*) view codeStatementsFromJson: (NSArray *)json
{
    // Add code statements
    
    [json enumerateObjectsUsingBlock:^(NSMutableDictionary *jsonStatement, NSUInteger idx, BOOL *stop) {
        ZS_StatementView* statementView = nil;
        
        NSString *key = jsonStatement.allKeys.firstObject;
        
        if ([key isEqualToString:@"on_event"])
        {
            statementView =  [self onEventStatementViewFromJson: jsonStatement beforeAddingSubstatementsBlock:^(ZS_StatementView *statementView) {
                // this has to happen before any sub-statements are added!
                NSSet *initialProperties = [NSSet setWithArray:jsonStatement[@"on_event"][@"parameters"]];
                statementView.propertyScope = [view.propertyScope nestedScopeForCode:jsonStatement[key][@"code"]
                                                                              atLine:idx
                                                                   initialProperties:initialProperties];
            }];
        }
        else if ([key isEqualToString:@"trigger_event"])
        {
            statementView =  [self triggerEventStatementViewFromJson: jsonStatement];
        }
        else if ([key isEqualToString:@"set"])
        {
            statementView =  [self setStatementViewFromJson: jsonStatement];
        }
        else if ([key isEqualToString:@"call"])
        {
            statementView = [self callStatementViewFromJson:jsonStatement];
        }
        else if ([key isEqualToString:@"if"])
        {
            statementView =  [self ifStatementViewFromJson: jsonStatement beforeAddingSubstatementsBlock:^(ZS_StatementView *statementView) {
                statementView.propertyScope = [view.propertyScope nestedScopeForCode:jsonStatement[key][@"true"]
                                                                              atLine:idx
                                                                   initialProperties:[NSSet set]];
            }];
        }
        else
        {
            statementView = [[ZS_StatementView alloc]init];
            [statementView addArgumentLabelWithText:@"NOT IMPLEMENTED" touchBlock:nil];
        }
        __weak typeof(view) weakView = view;
        statementView.propertiesInScope = ^NSSet *() {
            return [weakView.propertyScope propertiesAtLine:idx];
        };
        [view addSubStatementView: statementView];
    }];
}
- (ZS_StatementView*) objectStatementViewFromJson:(NSMutableDictionary *)jsonObject
                   beforeAddingSubstatementsBlock:(void (^)(ZS_StatementView *))beforeSubstatementsBlock
{
    ZS_StatementView* view = [[ZS_StatementView alloc]initWithJson:jsonObject];
    
    // DEBUG
    //view.backgroundColor = [UIColor yellowColor];
    // END DEBUG
    
    view.jsonCode = jsonObject[@"code"];
    view.topLevelStatement = YES;

    // Properties
    NSDictionary* properties = jsonObject[@"properties"];
    if (properties.count)
    {
        [view addParametersLabelWithText:[ZS_JsonUtilities propertiesStringFromJson: properties]];
    }
    
    beforeSubstatementsBlock(view);

    // Code
    [self addToView: view codeStatementsFromJson: jsonObject[@"code"]];
    
    // Add <new code statement> button
    [view addNewStatementLabelWithTouchBlock:^(UILabel* label)
    {
        ZSToolboxView* toolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
        ZS_StatementChooserCollectionViewController* controller = [[ZS_StatementChooserCollectionViewController alloc]init];
        
        controller.jsonCodeBody = jsonObject[@"code"];
        controller.codeEditorViewController = self;
        controller.toolboxView = toolboxView;
  
        self.statementChooserController = controller;
        
        [toolboxView setPagingEnabled:NO];
        [toolboxView addContentView: controller.collectionView title: @"STATEMENT CHOOSER"];
        [self.view addSubview: toolboxView];
        [toolboxView showAnimated:YES];
    }];
    
    // Layout subviews;
    [view layoutStatementSubviews];
    
    return view;
}
- (ZS_StatementView*) onEventStatementViewFromJson:(NSMutableDictionary *)json
                    beforeAddingSubstatementsBlock:(void (^)(ZS_StatementView *))beforeSubstatementsBlock
{
    ZS_StatementView* view = [[ZS_StatementView alloc]initWithJson:json];
    view.delegate = self;
    view.jsonCode = json[@"on_event"][@"code"];
    
    // statement name
    [view addNameLabelWithText:@"ON EVENT"];
    
    // event name
    [view addArgumentLabelWithText: json[@"on_event"][@"name"]
                        touchBlock:^(UILabel* label)
     {
         ZSToolboxView* toolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
         ZS_EventChooserCollectionViewController* controller = [[ZS_EventChooserCollectionViewController alloc]init];
         
         controller.json = json;
         controller.codeEditorViewController = self;
         controller.toolboxView = toolboxView;
         
         self.eventChooserController = controller;
         
         [toolboxView setPagingEnabled:NO];
         [toolboxView addContentView: controller.collectionView title: @"EVENT CHOOSER"];
         [self.view addSubview: toolboxView];
         [toolboxView showAnimated:YES];
     }];

    // parameters
    NSArray* parameters = json[@"on_event"][@"parameters"];
    if (parameters.count)
    {
        [view addParametersLabelWithText:[ZS_JsonUtilities parametersStringFromJson: parameters]];
    }
    
    beforeSubstatementsBlock(view);
    
    [self addToView: view codeStatementsFromJson:json[@"on_event"][@"code"]];
    
    // Add <new code statement> button
    [view addNewStatementLabelWithTouchBlock:^(UILabel* label)
     {
         ZSToolboxView* toolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
         ZS_StatementChooserCollectionViewController* controller = [[ZS_StatementChooserCollectionViewController alloc]init];
         
         controller.jsonCodeBody = json[@"on_event"][@"code"];
         controller.codeEditorViewController = self;
         controller.toolboxView = toolboxView;
         
         self.statementChooserController = controller;
         
         [toolboxView setPagingEnabled:NO];
         [toolboxView addContentView: controller.collectionView title: @"STATEMENT CHOOSER"];
         [self.view addSubview: toolboxView];
         [toolboxView showAnimated:YES];
     }];
    return view;
}
        
- (ZS_StatementView*) ifStatementViewFromJson:(NSMutableDictionary *)json
               beforeAddingSubstatementsBlock:(void (^)(ZS_StatementView *))beforeSubstatementBlock
{
    ZS_StatementView* view = [[ZS_StatementView alloc]initWithJson:json];
    view.delegate = self;
    view.jsonCode = json[@"if"][@"true"];
    
    // statement name
    [view addNameLabelWithText:@"IF"];
    
    // boolean expression
    NSString* expressionString = [ZS_JsonUtilities expressionStringFromJson: json[@"if"][@"test"]];
    [view addArgumentLabelWithText: expressionString
                        touchBlock:^(UILabel* label)
     {
         [self performSegueWithIdentifier:@"to expression editor" sender: label];
     }];
    
    beforeSubstatementBlock(view);
    
    [self addToView: view codeStatementsFromJson:json[@"if"][@"true"]];
    
    // Add <new code statement> button
    [view addNewStatementLabelWithTouchBlock:^(UILabel* label)
     {
         ZSToolboxView* toolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
         ZS_StatementChooserCollectionViewController* controller = [[ZS_StatementChooserCollectionViewController alloc]init];
         
         controller.jsonCodeBody = json[@"if"][@"true"];
         controller.codeEditorViewController = self;
         controller.toolboxView = toolboxView;
         
         self.statementChooserController = controller;
         
         [toolboxView setPagingEnabled:NO];
         [toolboxView addContentView: controller.collectionView title: @"STATEMENT CHOOSER"];
         [self.view addSubview: toolboxView];
         [toolboxView showAnimated:YES];
     }];
    
    return view;
}
- (ZS_StatementView*) triggerEventStatementViewFromJson:(NSMutableDictionary *)json
{
    ZS_StatementView* view = [[ZS_StatementView alloc]initWithJson:json];
    view.delegate = self;
    
    // statement name
    [view addNameLabelWithText:@"TRIGGER EVENT"];

    // event name
    [view addArgumentLabelWithText: json[@"trigger_event"][@"name"]
                        touchBlock:^(UILabel* label)
     {
         ZSToolboxView* toolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
         ZS_EventChooserCollectionViewController* controller = [[ZS_EventChooserCollectionViewController alloc]init];
         
         controller.json = json;
         controller.codeEditorViewController = self;
         controller.toolboxView = toolboxView;
         
         self.eventChooserController = controller;
         
         [toolboxView setPagingEnabled:NO];
         [toolboxView addContentView: controller.collectionView title: @"EVENT CHOOSER"];
         [self.view addSubview: toolboxView];
         [toolboxView showAnimated:YES];
     }];
    // parameters
    NSArray* parameters = json[@"trigger_event"][@"parameters"];
    if (parameters.count)
    {
        [view addParametersLabelWithText:[ZS_JsonUtilities parametersStringFromJson: parameters]];
    }
    return view;
}
- (ZS_StatementView*) setStatementViewFromJson:(NSMutableDictionary *)json
{
    ZS_StatementView* view = [[ZS_StatementView alloc]initWithJson:json];
    view.delegate = self;
    
    // Statement name SET
    [view addNameLabelWithText:@"SET"];
    
    // Variable name
    __weak typeof(view) weakView = view;
    [view addArgumentLabelWithText: json[@"set"][0]
                        touchBlock:^(UILabel* label)
     {
         ZSToolboxView* variableToolboxView = [[ZSToolboxView alloc] initWithFrame:CGRectMake(19, 82, 282, 361)];
         
          ZS_VariableChooserCollectionViewController *variableChooserController =
         [[ZS_VariableChooserCollectionViewController alloc]init];
         variableChooserController.variables = weakView.propertiesInScope().allObjects;
         variableChooserController.codeEditorViewController = self;
         variableChooserController.toolboxView = variableToolboxView;
         variableChooserController.json = json;
         self.variableChooserController = variableChooserController;
         
         [variableToolboxView setPagingEnabled:NO];
         [variableToolboxView addContentView: variableChooserController.collectionView
                                       title: @"VARIABLE CHOOSER"];
         [self.view addSubview: variableToolboxView];
         
         [variableToolboxView showAnimated:YES];
     }];
    // Statement name TO
    [view addNameLabelWithText:@"TO"];
    
    // Variable value
    NSString* variableString = [ZS_JsonUtilities expressionStringFromJson: json[@"set"][1]];
    [view addArgumentLabelWithText: variableString
                        touchBlock:^(UILabel* label)
     {
         [self performSegueWithIdentifier:@"to expression editor" sender: label];
     }];
    return view;
}
- (ZS_StatementView*) callStatementViewFromJson:(NSMutableDictionary *)json
{
    ZS_StatementView* view = [[ZS_StatementView alloc]initWithJson:json];
    view.delegate = self;
    
    // Method name
    [view addNameLabelWithText:json[@"call"][@"method"]];
    
    // Left parenthesis
    [view addNameLabelWithText:@"("];
    
    // Method parameters
    
    // The manifest parameters hold extra metadata about what each parameter accepts
    NSArray *manifestParameters = [ZS_JsonUtilities manifestForMethodIdentifier:json[@"call"][@"method"]][@"parameters"];
    NSMutableArray *parameters = json[@"call"][@"parameters"];
    for (NSInteger i = 0; i < parameters.count; i++)
    {
        NSDictionary *manifestParameter = manifestParameters[i];
        [view addArgumentLabelWithText: [ZS_JsonUtilities expressionStringFromJson: parameters[i]]
                            touchBlock:^(UILabel* label)
         {
             label.tag = i;
             if ([manifestParameter[@"types"][0] isEqualToString:@"string"]) {
                 UIAlertView *alertView = [[MTBlockAlertView alloc] initWithTitle:@"String Value"
                                                                          message:@"Enter a string"
                                                                completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                    NSString *text = [alertView textFieldAtIndex:0].text;
                                                                    if (text && text.length > 0) {
                                                                        parameters[i] = text;
                                                                        [self reloadFromJson];
                                                                    }
                                                                }
                                                                cancelButtonTitle:@"Cancel"
                                                                otherButtonTitles:@"OK", nil];
                 
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView show];
             } else {
                 [self performSegueWithIdentifier:@"to expression editor" sender: label];
             }
         }];

        // Comma
        if (i < parameters.count-1)
        {
            [view addNameLabelWithText:@","];
        }
    }
    // Right parenthesis
    [view addNameLabelWithText:@")"];

    return view;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UILabel*)label
{
    ZS_StatementView* statementView = (ZS_StatementView*)label.superview;
    
    if ([[segue identifier] isEqualToString:@"to expression editor"])
    {
        ZS_ExpressionViewController* c = (ZS_ExpressionViewController*)segue.destinationViewController;
        c.variableNames = statementView.propertiesInScope().allObjects;
        
        if ([statementView.json.allKeys[0] isEqualToString:@"if"])
        {
            // pass a mutable copy of json to the expression editor controller
            NSObject* json = statementView.json[@"if"][@"test"];
            c.json = [json isKindOfClass:[NSMutableDictionary class]] ? ((NSMutableDictionary*)json).deepMutableCopy : json;
            
            // code block executed upon exiting expression editor
            c.didFinish = ^(NSObject* json)
            {
                if (json)
                {
                    statementView.json[@"if"][@"test"] = json;
                    [self reloadFromJson];
                }
                [self dismissViewControllerAnimated: YES completion: nil];
            };
        }
        else if([statementView.json.allKeys[0] isEqualToString:@"set"])
        {
            // pass a mutable copy of json to the expression editor controller
            NSObject* json = statementView.json[@"set"][1];
            c.json = [json isKindOfClass:[NSMutableDictionary class]] ? ((NSMutableDictionary*)json).deepMutableCopy : json;
            
            // code block executed upon exiting expression editor
            c.didFinish = ^(NSObject* json)
            {
                if (json)
                {
                    statementView.json[@"set"][1] = json;
                    [self reloadFromJson];
                }
                [self dismissViewControllerAnimated: YES completion: nil];
            };
        }
        else if([statementView.json.allKeys[0] isEqualToString:@"call"])
        {
            // pass a mutable copy of json to the expression editor controller
            NSInteger parameterNumber = label.tag;
            NSObject* json = statementView.json[@"call"][@"parameters"][parameterNumber];
            c.json = [json isKindOfClass:[NSMutableDictionary class]] ? ((NSMutableDictionary*)json).deepMutableCopy : json;
            
            // code block executed upon exiting expression editor
            c.didFinish = ^(NSObject* json)
            {
                if (json)
                {
                    statementView.json[@"call"][@"parameters"][parameterNumber] = json;
                    [self reloadFromJson];
                }
                [self dismissViewControllerAnimated: YES completion: nil];
            };
        }
    }
    else if ([[segue identifier] isEqualToString:@"to json viewer"])
    {
        ZS_JsonViewController* c  = (ZS_JsonViewController*)segue.destinationViewController;
        c.json = self.json;
    }
}
#pragma mark ZS_StatementViewDelegate

- (void) statementViewLongPressed:(ZS_StatementView*) view
{
    // Create menu items
    UIMenuItem* menuItemCopy = [[UIMenuItem alloc]initWithTitle: @"copy"
                                                         action: @selector(menuItemCopy)];
    UIMenuItem* menuItemDelete = [[UIMenuItem alloc]initWithTitle: @"del"
                                                           action: @selector(menuItemDelete)];
    // Add menu items to array
    NSMutableArray* menuItems = [NSMutableArray arrayWithArray:@[menuItemCopy, menuItemDelete]];
    
    // If copy buffer is not empty, then add two more menu items
    if (self.statementCopyBuffer)
    {
        UIMenuItem* menuItemInsertAbove = [[UIMenuItem alloc]initWithTitle: @"insert ↑"
                                                                    action: @selector(menuItemInsertAbove)];
        UIMenuItem* menuItemInsertBelow = [[UIMenuItem alloc]initWithTitle: @"insert ↓"
                                                                    action: @selector(menuItemInsertBelow)];
        [menuItems addObject: menuItemInsertAbove];
        [menuItems addObject: menuItemInsertBelow];
    }
    
    // Create menu controller
    [view becomeFirstResponder];
    UIMenuController* menu = [UIMenuController sharedMenuController];
    [menu setMenuItems: menuItems];
    [menu setTargetRect: CGRectZero inView:view];
    [menu setMenuVisible:YES animated:YES];
}
#pragma mark Menu Methods

- (void) menuItemCopy
{
    self.statementCopyBuffer = self.selectedStatementView.json.deepMutableCopy;
}
- (void)menuItemDelete
{
    NSMutableArray* parentCodeBlock = ((ZS_StatementView*)self.selectedStatementView.superview).jsonCode;
    
    for (NSInteger i = 0; i < parentCodeBlock.count; i++)
    {
        if (parentCodeBlock[i] == self.selectedStatementView.json)
        {
            [parentCodeBlock removeObjectAtIndex:i];
            break;
        }
    }
    [self reloadFromJson];
}
- (void)menuItemInsertAbove
{
    NSMutableArray* parentCodeBlock = ((ZS_StatementView*)self.selectedStatementView.superview).jsonCode;
    
    for (NSInteger i = 0; i < parentCodeBlock.count; i++)
    {
        if (parentCodeBlock[i] == self.selectedStatementView.json)
        {
            [parentCodeBlock insertObject:self.statementCopyBuffer.deepMutableCopy atIndex:i];
            break;
        }
    }
    [self reloadFromJson];
}
- (void)menuItemInsertBelow
{
    NSMutableArray* parentCodeBlock = ((ZS_StatementView*)self.selectedStatementView.superview).jsonCode;
    
    for (NSInteger i = 0; i < parentCodeBlock.count; i++)
    {
        if (parentCodeBlock[i] == self.selectedStatementView.json)
        {
            // if it's the last statement in the code block
            if (i == parentCodeBlock.count - 1)
            {
                [parentCodeBlock addObject:self.statementCopyBuffer.deepMutableCopy];
            }
            else
            {
                [parentCodeBlock insertObject:self.statementCopyBuffer.deepMutableCopy atIndex:i+1];
            }
            break;
        }
    }
    [self reloadFromJson];
}

#pragma mark Tutorial Hooks

- (void) scrollToRight {
    CGPoint rightOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.bounds.size.width, 0);
    [self.scrollView setContentOffset:rightOffset animated:YES];
}

@end
