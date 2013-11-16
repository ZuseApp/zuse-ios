#import <Foundation/Foundation.h>

@interface ZSCodeBoolExpression : NSObject

@property (strong, nonatomic) NSString *oper;
@property (strong, nonatomic) NSString *exp1;
@property (strong, nonatomic) NSString *exp2;
@property (strong, nonatomic) NSString *text;

+(id)expressionWithOper:(NSString *)oper
                   exp1:(NSString *)exp1
                   exp2:(NSString *)exp2;
+(id)expressionWithJSON:(NSDictionary *)json;

@end
