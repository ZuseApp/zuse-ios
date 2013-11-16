#import "ZSCodeSuite.h"
#import "ZSCodeSetStatement.h"
#import "ZSCodeIfStatement.h"
#import "ZSCodeCallStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeSuite()
@property (strong, nonatomic) NSMutableArray *statements;
@end

@implementation ZSCodeSuite

-(id)initWithLevel:(NSInteger)level
{
    if (self = [super init])
    {
        self.statements = [[NSMutableArray alloc]init];
        self.level = level;
    }
    return self;
}

+(id)suiteWithJSON:(NSArray *)JSONSuite
             level:(NSInteger)level
{
    ZSCodeSuite *suite = [[ZSCodeSuite alloc]initWithLevel:level];
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
    }
    return suite;
}

-(void)addStatement:(ZSCodeStatement *)statement
{
    // add statement
    [self.statements addObject:statement];
    
    // add new code line if needed
    if ([self.codeLines count] == 0)
    {
        [self.codeLines addObject:[ZSCodeLine lineWithText:@"+"
                                                      type:NEW_STATEMENT_TYPE
                                               indentation:self.level]];
    }
    
    // insert code lines before new code line
    for (ZSCodeLine  *line in statement.codeLines)
    {
        [self.codeLines insertObject:line
                             atIndex:[self.codeLines count]-1];
    }
}

@end