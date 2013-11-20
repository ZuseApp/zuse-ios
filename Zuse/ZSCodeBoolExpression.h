#import <Foundation/Foundation.h>

@interface ZSCodeBoolExpression : NSObject

@property (strong, nonatomic) NSString *oper; // '==', or '=>', or '<=', or '!='
@property (strong, nonatomic) NSObject *exp1; // either NSDictionary (variable) or NSString (constant)
@property (strong, nonatomic) NSObject *exp2; // either NSDictionary (variable) or NSString (constant)
@property (strong, nonatomic) NSString *text; // boolean expression converted to text

+(id)expressionWithOper:(NSString *)oper
                   exp1:(NSObject *)exp1
                   exp2:(NSObject *)exp2;
+(id)expressionWithJSON:(NSDictionary *)json;

@end
