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
        self.level = 0;
    }
    return self;
}

+(id)suiteWithJSON:(NSArray *)JSONSuite
             level:(NSInteger)level
            parent:(ZSCodeStatement *)parentStatement
{
    if (JSONSuite == nil) {
        return nil;
    }

    // Create a new suite object
    ZSCodeSuite *suite = [[ZSCodeSuite alloc]init];
    suite.level = level;
    suite.parentStatement = parentStatement;
    
    // Process JSON suite
    for (NSDictionary *JSONStatement in JSONSuite)
    {
        NSString *statementName = [JSONStatement allKeys][0];
        
        // Process SET statement
        if ([statementName isEqualToString:@"set"])
        {
            [suite addStatement:[ZSCodeSetStatement statementWithJSON:JSONStatement
                                                                level:level]];
        }
        // Process CALL
        else if([statementName isEqualToString:@"call"])
        {
            [suite addStatement: [ZSCodeCallStatement statementWithJSON:JSONStatement
                                                                  level:level]];
        }
        // Process IF statement
        else if ([statementName isEqualToString:@"if"])
        {
            [suite addStatement:[ZSCodeIfStatement statementWithJSON:JSONStatement
                                                               level:level]];
        }
        // Process ON_EVENT statement
        else if ([statementName isEqualToString:@"on_event"])
        {
            [suite addStatement:[ZSCodeOnEventStatement statementWithJSON:JSONStatement
                                                                    level:level]];
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
        [lines addObjectsFromArray:s.codeLines];
    }
    
    
    // Decide on type of new statement
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
        type = ZSCodeLineStatementNew;
    
    // add new code line
    [lines addObject:[ZSCodeLine lineWithText:@"+"
                                         type:type
                                  indentation:self.level
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