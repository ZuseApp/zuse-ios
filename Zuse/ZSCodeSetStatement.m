#import "ZSCodeBoolExpression.h"
#import "ZSCodeSetStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeSetStatement()

@end

@implementation ZSCodeSetStatement

+(id)statementWithVariableName:(NSString *)name
                         value:(NSObject *)value
                         level:(NSInteger)level
{
    ZSCodeSetStatement *s = [[ZSCodeSetStatement alloc]init];
    s.variableName = name;
    s.variableValue = value;
    s.indentationLevel = level;
    return s;
}

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    NSString *name  = json[@"set"][0];
    NSObject *value = json[@"set"][1];
    
    // if value is call or get statement
    if([value isKindOfClass:[NSDictionary class]])
    {
        
        NSString *statementName = [((NSDictionary *)value) allKeys][0];
        
        if([statementName isEqualToString:@"call"])
        {
            value = [ZSCodeCallStatement statementWithJSON:(NSDictionary*)value
                                                     level:level];
        }
    }    
    return [self statementWithVariableName:name
                                     value:value
                                     level:level];
}

-(NSString *)variableValueStringValue
{
    NSString *value;
    
    // value is call statement
    if ([self.variableValue isKindOfClass: [ZSCodeCallStatement class]]) // variable value is call statement
    {
        //ZSCodeCallStatement *call = (ZSCodeCallStatement *)self.variableValue;
        value = @"!!!not implemented!!!";
    }
    // value is get statement
    else if([self.variableValue isKindOfClass: [NSDictionary class]])
    {
        value = ((NSDictionary *)self.variableValue)[@"get"];
    }
    // value is a number
    else if([self.variableValue isKindOfClass: [NSNumber class]])
    {
        NSNumber *n = (NSNumber *)self.variableValue;
        value = [ZSCodeBoolExpression isBooleanType:n] ? [n integerValue]? @"true" : @"false" : [n stringValue];
    }
    // value is a text
    else
    {
        value = (NSString *)self.variableValue;
    }
    
    return value;
}

-(NSArray *) codeLines
{
    // Create code line object
    ZSCodeLine *line = [ZSCodeLine lineWithType:ZSCodeLineStatementSet
                                    indentation:self.indentationLevel
                                      statement:self];
    // Put code line in array
    return [NSMutableArray arrayWithObject:line];
}

-(NSDictionary *) JSONObject
{
    return @{@"set" : @[self.variableName, self.variableValue]};
}

@end
