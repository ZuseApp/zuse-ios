#import "ZSCodeStatementSet.h"
#import "ZSCodeLine.h"

@implementation ZSCodeStatementSet

+ (id) emptyWithParentSuite:(ZSCodeSuite *)suite
{
    ZSCodeStatementSet *s = [[ZSCodeStatementSet alloc]initWithParentSuite:suite];
    s.variableName = @"...";
    s.variableValue = @"...";
    return s;
}

- (id) initWithJSON:(NSDictionary *)json
        parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super initWithParentSuite:suite])
    {
        NSString *name  = json[@"set"][0];
        NSObject *value = json[@"set"][1];
        
        // if value is call or get statement
        if([value isKindOfClass:[NSDictionary class]])
        {
            NSString *statementName = [((NSDictionary *)value) allKeys][0];
            
            if([statementName isEqualToString:@"call"])
            {
                value = [[ZSCodeStatementCall alloc] initWithJSON:(NSDictionary*)value
                                                      parentSuite:self.parentSuite];
            }
        }
        self.variableName = name;
        self.variableValue = value;
    }
    return self;
}

-(NSString *)variableValueStringValue
{
    NSString *value;
    
    // value is call statement
    if ([self.variableValue isKindOfClass: [ZSCodeStatementCall class]]) // variable value is call statement
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
        value = [ZSCodeStatementSet isBooleanType:n] ? [n integerValue]? @"true" : @"false" : [n stringValue];
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

+(BOOL)isBooleanType:(NSNumber *)n
{
    return strcmp([n objCType], @encode(BOOL)) == 0;
}

@end
