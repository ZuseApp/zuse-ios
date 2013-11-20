#import "ZSCodeSetStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeSetStatement()

@property (strong, nonatomic) NSString *variableName;
@property (strong, nonatomic) NSObject *variableValue; // either NSString, or ZSCodeCallStatement, or NSDictionary (get)

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

-(NSArray *) codeLines
{
    // Form text for code line
    NSString *value;
    
    // value is call statement
    if ([self.variableValue isKindOfClass: [ZSCodeCallStatement class]]) // variable value is call statement
    {
        ZSCodeCallStatement *call = (ZSCodeCallStatement *)self.variableValue;
        ZSCodeLine *line = call.codeLines[0];
        value = line.text;
    }
    // value is get statement
    else if([self.variableValue isKindOfClass: [NSDictionary class]])
    {
        value = ((NSDictionary *)self.variableValue)[@"get"];
    }
    // value is constant (text)
    else
    {
        value = (NSString *)self.variableValue;
    }
    NSString *text =  [NSString stringWithFormat:@"SET %@ TO %@", self.variableName, value];
    
    // Create code line object
    ZSCodeLine *line = [ZSCodeLine lineWithText:text
                                           type:ZSCodeLineStatementSet
                                    indentation:self.level];
    // Put code line in array
    return [NSMutableArray arrayWithObject:line];
}

-(NSDictionary *) JSONObject
{
    return @{@"set" : @[self.variableName, self.variableValue]};
}

@end
