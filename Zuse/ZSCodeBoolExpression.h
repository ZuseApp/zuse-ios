#import <Foundation/Foundation.h>

@interface ZSCodeBoolExpression : NSObject

@property (strong, nonatomic) NSString *oper; // '==', or '=>', or '<=', or '!='
@property (strong, nonatomic) NSObject *exp1; // either NSDictionary (variable) or NSString (constant) or NSNumber
@property (strong, nonatomic) NSObject *exp2; // either NSDictionary (variable) or NSString (constant) or NSNumber

+(id)expressionWithOper:(NSString *)oper
                   exp1:(NSObject *)exp1
                   exp2:(NSObject *)exp2;
+(id)expressionWithJSON:(NSDictionary *)json;
+(BOOL)isBooleanType:(NSNumber *)n;


-(NSString *)stringValue;

@end
