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
{
    if (JSONSuite == nil) {
        return nil;
    }

    // Create a new suite object
    ZSCodeSuite *suite = [[ZSCodeSuite alloc]init];
    suite.parentStatement = parentStatement;
    
    // parentStatement = nil if this suite is of the highest level (just code)
    NSInteger indentationLevel = parentStatement == nil ? 0 : parentStatement.level + 1;
    
    // Process JSON suite
    for (NSDictionary *JSONStatement in JSONSuite)
    {
        NSString *statementName = [JSONStatement allKeys][0];
        
        // Process SET statement
        if ([statementName isEqualToString:@"set"])
        {
            [suite addStatement:[ZSCodeSetStatement statementWithJSON:JSONStatement
                                                                level:indentationLevel]];
        }
        // Process CALL
        else if([statementName isEqualToString:@"call"])
        {
            [suite addStatement: [ZSCodeCallStatement statementWithJSON:JSONStatement
                                                                  level:indentationLevel]];
        }
        // Process IF statement
        else if ([statementName isEqualToString:@"if"])
        {
            [suite addStatement:[[ZSCodeIfStatement alloc] initWithJSON:JSONStatement
                                                                  level:indentationLevel]];
        }
        // Process ON_EVENT statement
        else if ([statementName isEqualToString:@"on_event"])
        {
            [suite addStatement:[[ZSCodeOnEventStatement alloc] initWithJSON:JSONStatement
                                                                       level:indentationLevel]];
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
        type = ZSCodeLineStatementNew;
    
    
    // Decide on indentation level
    // parentStatement = nil if this suite is of the highest level (just code)
    NSInteger level = self.parentStatement == nil ? 0 : self.parentStatement.level + 1;
    
    // add new code line
    [lines addObject:[ZSCodeLine lineWithText:@"+"
                                         type:type
                                  indentation:level
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