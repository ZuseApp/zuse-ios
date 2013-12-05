#import "ZSCodeSuite.h"
#import "ZSCodeSetStatement.h"
#import "ZSCodeIfStatement.h"
#import "ZSCodeCallStatement.h"
#import "ZSCodeOnEventStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeSuite()

@end

@implementation ZSCodeSuite


-(id)init
{
    if (self = [super init])
    {
        self.statements = [[NSMutableArray alloc]init];
    }
    return self;
}

+(id)suiteWithJSON:(NSArray *)JSONSuite
            parent:(ZSCodeStatement *)parentStatement
  indentationLevel:(NSInteger)level
{
    if (JSONSuite == nil) {
        return nil;
    }

    // Create a new suite object
    ZSCodeSuite *suite = [[ZSCodeSuite alloc]init];
    suite.parentStatement = parentStatement;
    suite.indentationLevel = level;
    
    // Process JSON suite
    for (NSDictionary *JSONStatement in JSONSuite)
    {
        NSString *statementName = [JSONStatement allKeys][0];
        
        // Process SET statement
        if ([statementName isEqualToString:@"set"])
        {
            [suite addStatement:[[ZSCodeSetStatement alloc] initWithJSON:JSONStatement
                                                             parentSuite:suite]];
        }
        // Process CALL
        else if([statementName isEqualToString:@"call"])
        {
            [suite addStatement: [[ZSCodeCallStatement alloc] initWithJSON:JSONStatement
                                                               parentSuite:suite]];
        }
        // Process IF statement
        else if ([statementName isEqualToString:@"if"])
        {
            [suite addStatement:[[ZSCodeIfStatement alloc] initWithJSON:JSONStatement
                                                            parentSuite:suite]];
        }
        // Process ON_EVENT statement
        else if ([statementName isEqualToString:@"on_event"])
        {
            [suite addStatement:[[ZSCodeOnEventStatement alloc] initWithJSON:JSONStatement
                                                                 parentSuite:suite]];
        }
    }
    return suite;
}

-(void)addStatement:(ZSCodeStatement *)statement
{
    [self.statements addObject:statement];
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
            [lines addObjectsFromArray:statement.trueSuite.codeLines];
            
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
            [lines addObjectsFromArray:statement.code.codeLines];
        }
        
        // 'SET' statement
        else if ([s isKindOfClass:[ZSCodeSetStatement class]])
        {
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeLineStatementSet
                                          indentation:self.indentationLevel
                                            statement:s]];
        }
        
        // 'CALL' statement
        else if ([s isKindOfClass:[ZSCodeCallStatement class]])
        {
            [lines addObject:[ZSCodeLine lineWithType: ZSCodeLineStatementCall
                                          indentation:self.indentationLevel
                                            statement:s]];
        }
    }
    
    // Decide on type of 'new statement'
    NSString *type;
    if ([self.parentStatement isKindOfClass:[ZSCodeOnEventStatement class]])
    {
        type = ZSCodeLineStatementNewInsideOnEvent;
    }
    else if([self.parentStatement isKindOfClass:[ZSCodeIfStatement class]])
    {
        type = ZSCodeLineStatementNewInsideIf;
    }
    else
        type = ZSCodeLineStatementNewTopLevel;
    
    // add new code line
    [lines addObject:[ZSCodeLine lineWithType:type
                                  indentation:self.indentationLevel
                                    statement:nil]];
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