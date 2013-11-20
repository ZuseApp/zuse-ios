#import "ZSCodeBoolExpression.h"

@implementation ZSCodeBoolExpression

+(id)expressionWithOper:(NSString *) oper
                   exp1:(NSObject *) e1
                   exp2:(NSObject *) e2
{
    ZSCodeBoolExpression *e = [[ZSCodeBoolExpression alloc]init];
    e.oper = oper;
    e.exp1 = e1;
    e.exp2 = e2;
    
    // form text
    e1 = [e1 isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)e1)[@"get"] : e1;
    e2 = [e2 isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)e2)[@"get"] : e2;
    
    e.text = [NSString stringWithFormat:@"%@ %@ %@", e1, oper, e2];
    return e;
}

+(id)expressionWithJSON:(NSDictionary *)json
{
    NSString *oper = [json allKeys][0];
    return [self expressionWithOper:oper
                               exp1:json[oper][0]
                               exp2:json[oper][1]];
}

@end
