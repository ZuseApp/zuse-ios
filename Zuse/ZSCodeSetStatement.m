#import "ZSCodeBoolExpression.h"
#import "ZSCodeSetStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeSetStatement()

@end

@implementation ZSCodeSetStatement


- (id) initWithVariableName:(NSString *)name
                      value:(NSObject *)value
                parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        self.variableName = name;
        self.variableValue = value;
        self.parentSuite = suite;
    }
    return self;
}

- (id) initWithJSON:(NSDictionary *)json
        parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        NSString *name  = json[@"set"][0];
        NSObject *value = json[@"set"][1];
        
        // if value is call or get statement
        if([value isKindOfClass:[NSDictionary class]])
        {
            NSString *statementName = [((NSDictionary *)value) allKeys][0];
            
            if([statementName isEqualToString:@"call"])
            {
                value = [[ZSCodeCallStatement alloc] initWithJSON:(NSDictionary*)value
                                                      parentSuite:self.parentSuite];
            }
        }
        self.variableName = name;
        self.variableValue = value;
        self.parentSuite = suite;
    }
    return self;
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

-(NSDictionary *) JSONObject
{
    return @{@"set" : @[self.variableName, self.variableValue]};
}

@end
