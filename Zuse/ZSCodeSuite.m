#import "ZSCodeSuite.h"
#import "ZSCodeStatementSet.h"
#import "ZSCodeStatementIf.h"
#import "ZSCodeStatementCall.h"
#import "ZSCodeStatementOnEvent.h"
#import "ZSCodeLine.h"
#import "ZSCodeStatementNew.h"

@implementation ZSCodeSuite

- (id) initWithParentStatement: (ZSCodeStatement *)s
{
    if (self = [super init])
    {
        self.parentStatement = s;
        self.statements = [[NSMutableArray alloc]init];
    }
    return self;
}

-(id) initWithJSON:(NSArray *)JSONSuite
   parentStatement:(ZSCodeStatement *)p
{
    if (JSONSuite == nil || (self = [super init]) == nil)
    {
        return nil;
    }
    self.statements = [[NSMutableArray alloc]init];
    self.parentStatement = p;
    
    // Process JSON suite
    for (NSDictionary *JSONStatement in JSONSuite)
    {
        NSString *statementName = [JSONStatement allKeys][0];
        
        // Process SET statement
        if ([statementName isEqualToString:@"set"])
        {
            [self addStatement:[[ZSCodeStatementSet alloc] initWithJSON:JSONStatement
                                                            parentSuite:self]];
        }
        // Process CALL
        else if([statementName isEqualToString:@"call"])
        {
            [self addStatement: [[ZSCodeStatementCall alloc] initWithJSON:JSONStatement
                                                              parentSuite:self]];
        }
        // Process IF statement
        else if ([statementName isEqualToString:@"if"])
        {
            [self addStatement:[[ZSCodeStatementIf alloc] initWithJSON:JSONStatement
                                                           parentSuite:self]];
        }
        // Process ON_EVENT statement
        else if ([statementName isEqualToString:@"on_event"])
        {
            [self addStatement:[[ZSCodeStatementOnEvent alloc] initWithJSON:JSONStatement
                                                                parentSuite:self]];
        }
    }
    
    return self;
}

-(void)addStatement:(ZSCodeStatement *)statement
{
    [self.statements addObject:statement];
}

-(void)addEmptyStatementWithType:(ZSCodeStatementType)type
{
    switch (type)
    {
        case ZSCodeStatementTypeSet:
            [self.statements addObject: [ZSCodeStatementSet emptyWithParentSuite:self]];
            break;
        case ZSCodeStatementTypeIf:
            [self.statements addObject: [ZSCodeStatementIf emptyWithParentSuite:self]];
            break;
        case ZSCodeStatementTypeOnEvent:
            [self.statements addObject: [ZSCodeStatementOnEvent emptyWithParentSuite:self]];
            break;
        case ZSCodeStatementTypeCall:
            break;
        default:
            @throw @"ZSCodeSuite: Unknown code statement type.";
            break;
    }
}

-(NSArray *) codeLines
{
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    
    // Generate code lines from all statements
    for (ZSCodeStatement *s in self.statements)
    {
        // 'IF' statement
        if ([s isKindOfClass:[ZSCodeStatementIf class]])
        {
            ZSCodeStatementIf *statement = (ZSCodeStatementIf *)s;
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeStatementTypeIf
                                            statement: statement]];
            [lines addObjectsFromArray: statement.trueSuite.codeLines];
            
            // ELSE block of if statement
            // ...
            
        }
        // 'ON EVENT' statement
        else if ([s isKindOfClass:[ZSCodeStatementOnEvent class]])
        {
            ZSCodeStatementOnEvent *statement = (ZSCodeStatementOnEvent *)s;
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeStatementTypeOnEvent
                                            statement: statement]];
            [lines addObjectsFromArray: statement.code.codeLines];
        }
        // 'SET' statement
        else if ([s isKindOfClass:[ZSCodeStatementSet class]])
        {
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeStatementTypeSet
                                            statement: s]];
        }
        // 'CALL' statement
        else if ([s isKindOfClass:[ZSCodeStatementCall class]])
        {
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeStatementTypeCall
                                            statement: s]];
        }
    }
    // add new code line
    [lines addObject:[ZSCodeLine lineWithType: ZSCodeStatementTypeNew
                                    statement: [[ZSCodeStatementNew alloc] initWithParentSuite: self]]];
    return lines;
}

-(NSArray *) JSONObject
{
    NSMutableArray *json = [[NSMutableArray alloc]init];
    for (ZSCodeStatement *s in self.statements)
    {
        [json addObject:s.JSONObject];
    }
    return json;
}

- (NSInteger) indentationLevel
{
    ZSCodeSuite *parentSuite = self.parentStatement.parentSuite;
    return parentSuite ? parentSuite.indentationLevel + 1  : 0;
}

@end