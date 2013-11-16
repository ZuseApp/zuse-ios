#import "ZSCodeBoolExpression.h"

@implementation ZSCodeBoolExpression

+(id)expressionWithOper:(NSString*)oper exp1:(NSString *)e1 exp2:(NSString*)e2
{
    ZSCodeBoolExpression *e = [[ZSCodeBoolExpression alloc]init];
    e.oper = oper;
    e.exp1 = e1;
    e.exp2 = e2;
    e.text = [NSString stringWithFormat:@"%@ %@ %@", e1, oper, e2];
    return e;
}

+(id)expressionWithJSON:(NSDictionary *)json
{
    NSString *oper = [json allKeys][0];
    return [self expressionWithOper:oper
                               exp1:json[oper][0][@"get"]
                               exp2:json[oper][1][@"get"]];
}

@end
