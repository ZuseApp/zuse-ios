#import "ZSCodeSuite.h"
#import "ZSCodeSetStatement.h"
#import "ZSCodeIfStatement.h"
#import "ZSCodeCallStatement.h"
#import "ZSCodeOnEventStatement.h"
#import "ZSCodeLine.h"
#import "ZSCodeNewStatement.h"

@interface ZSCodeSuite()

@end

@implementation ZSCodeSuite

-(id) initWithJSON:(NSArray *)JSONSuite
            parent:(ZSCodeStatement *)parentStatement
  indentationLevel:(NSInteger)level
{
    if (JSONSuite == nil || (self = [super init]) == nil)
    {
        return nil;
    }
    self.statements = [[NSMutableArray alloc]init];
    self.parentStatement = parentStatement;
    self.indentationLevel = level;
    
    // Process JSON suite
    for (NSDictionary *JSONStatement in JSONSuite)
    {
        NSString *statementName = [JSONStatement allKeys][0];
        
        // Process SET statement
        if ([statementName isEqualToString:@"set"])
        {
            [self addStatement:[[ZSCodeSetStatement alloc] initWithJSON:JSONStatement
                                                            parentSuite:self]];
        }
        // Process CALL
        else if([statementName isEqualToString:@"call"])
        {
            [self addStatement: [[ZSCodeCallStatement alloc] initWithJSON:JSONStatement
                                                              parentSuite:self]];
        }
        // Process IF statement
        else if ([statementName isEqualToString:@"if"])
        {
            [self addStatement:[[ZSCodeIfStatement alloc] initWithJSON:JSONStatement
                                                           parentSuite:self]];
        }
        // Process ON_EVENT statement
        else if ([statementName isEqualToString:@"on_event"])
        {
            [self addStatement:[[ZSCodeOnEventStatement alloc] initWithJSON:JSONStatement
                                                                parentSuite:self]];
        }
    }
    
    return self;
}

-(void)addStatement:(ZSCodeStatement *)statement
{
    [self.statements addObject:statement];
}

- (void) addEmptySetStatement
{
    ZSCodeSetStatement *s = [[ZSCodeSetStatement alloc] initWithVariableName: @"..."
                                                                       value: @"..."
                                                                 parentSuite: self];
    [self addStatement:s];
}


-(NSArray *) codeLines
{
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    
    // Generate code lines from all statements
    for (ZSCodeStatement *s in self.statements)
    {
        // 'IF' statement
        if ([s isKindOfClass:[ZSCodeIfStatement class]])
        {
            ZSCodeIfStatement *statement = (ZSCodeIfStatement *)s;
            
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeLineStatementIf
                                          indentation: self.indentationLevel
                                            statement: statement]];
            
            [lines addObjectsFromArray: statement.trueSuite.codeLines];
            
            // ELSE block of if statement
            // ...
            
        }
        
        // 'ON EVENT' statement
        else if ([s isKindOfClass:[ZSCodeOnEventStatement class]])
        {
            ZSCodeOnEventStatement *statement = (ZSCodeOnEventStatement *)s;
            
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeLineStatementOnEvent
                                          indentation: self.indentationLevel
                                            statement: statement]];
            
            [lines addObjectsFromArray: statement.code.codeLines];
        }
        
        // 'SET' statement
        else if ([s isKindOfClass:[ZSCodeSetStatement class]])
        {
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeLineStatementSet
                                          indentation: self.indentationLevel
                                            statement: s]];
        }
        
        // 'CALL' statement
        else if ([s isKindOfClass:[ZSCodeCallStatement class]])
        {
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeLineStatementCall
                                          indentation: self.indentationLevel
                                            statement: s]];
        }
    }
    
    // add new code line
    [lines addObject:[ZSCodeLine lineWithType: ZSCodeLineStatementNew
                                  indentation: self.indentationLevel
                                    statement: [[ZSCodeNewStatement alloc] initWithSuite: self]]];
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

@end