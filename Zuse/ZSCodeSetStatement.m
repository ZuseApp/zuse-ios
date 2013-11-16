#import "ZSCodeSetStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeSetStatement()
-(void)updateCodeLines;
@end

@implementation ZSCodeSetStatement

+(id)statementWithVariableName:(NSString *)name
                         value:(NSObject *)value
                         level:(NSInteger)level
{
    ZSCodeSetStatement *s = [[ZSCodeSetStatement alloc]init];
    s.variableName = name;
    s.variableValue = value;
    s.level = level;
    [s updateCodeLines];
    return s;
}

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    NSString *name  = json[@"set"][0];
    NSObject *value = json[@"set"][1];
    
    // if value is a method call
    if([value isKindOfClass:[NSDictionary class]])
    {
        value = [ZSCodeCallStatement statementWithJSON:(NSDictionary*)value
                                                 level:level];
    }
    return [self statementWithVariableName:name
                                     value:value
                                     level:level];
}

-(void)updateCodeLines
{
    // get value
    NSString *value;
    if ([self.variableValue isKindOfClass: [ZSCodeCallStatement class]]) // variable value is call statement
    {
        ZSCodeCallStatement *call = (ZSCodeCallStatement *)self.variableValue;
        ZSCodeLine *line = call.codeLines[0];
        value = line.text;
    }
    else
    {
        value = (NSString *)self.variableValue;
    }
    
    // form the line of code
    NSString *text = [NSString stringWithFormat:@"SET %@ TO %@", self.variableName, value];
    ZSCodeLine *line = [ZSCodeLine lineWithText:text
                                           type:SET_STATEMENT_TYPE
                                    indentation:self.level];
    // update codeLines
    self.codeLines[0] = line;
}

@end
