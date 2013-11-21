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
    NSString *e1 = [self.exp1 isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)self.exp1)[@"get"] : self.exp1;
    NSString *e2 = [self.exp2 isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)self.exp2)[@"get"] : self.exp2;
    
    return [NSString stringWithFormat:@"%@ %@ %@", e1, self.oper, e2];
}


@end
