#import "ZSCodeBoolExpression.h"

@interface ZSCodeBoolExpression()

//+(NSString *)convertToStringExpression:(NSObject *)exp;

@end

@implementation ZSCodeBoolExpression

+(id)expressionWithOper:(NSString *) oper
                   exp1:(NSObject *) e1
                   exp2:(NSObject *) e2
{
    ZSCodeBoolExpression *e = [[ZSCodeBoolExpression alloc]init];
    e.oper = oper;
    e.exp1 = e1;
    e.exp2 = e2;
    return e;
}

+(id)expressionWithJSON:(NSDictionary *)json
{
    NSString *oper = [json allKeys][0];
    return [self expressionWithOper:oper
                               exp1:json[oper][0]
                               exp2:json[oper][1]];
}

-(NSString *)stringValue
{
    NSString *e1 = [self convertToStringExpression:self.exp1];
    NSString *e2 = [self convertToStringExpression:self.exp2];
    
    return [NSString stringWithFormat:@"%@ %@ %@", e1, self.oper, e2];
}

+(BOOL)isBooleanType:(NSNumber *)n
{
    return strcmp([n objCType], @encode(BOOL)) == 0;
}

-(NSString *)convertToStringExpression:(NSObject *)exp
{
    NSString *str;
    
    // if it is get statement
    if ([exp isKindOfClass:[NSDictionary class]])
    {
        str = ((NSDictionary *)exp)[@"get"];
    }
    // if it is number
    else if ([exp isKindOfClass:[NSNumber class]])
    {
        NSNumber *n = (NSNumber *)exp;
        str = [ZSCodeBoolExpression isBooleanType:n] ? ([n integerValue] ? @"true" : @"false") : [n stringValue];
    }
    // if it is constant (string)
    else
        str = (NSString *)exp;
    
    return str;
}

@end
