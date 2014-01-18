#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"


@class ZSCodeBoolExpression;
@interface ZSCodeStatementIf : ZSCodeStatement

@property (strong, nonatomic) ZSCodeBoolExpression *boolExp;
@property (strong, nonatomic) ZSCodeSuite *trueSuite;
@property (strong, nonatomic) ZSCodeSuite *falseSuite;

@end

@interface ZSCodeBoolExpression : NSObject

@property (strong, nonatomic) NSString *sign; // '==', or '=>', or '<=', or '!='
@property (strong, nonatomic) NSObject *exp1; // either NSDictionary (variable) or NSString (constant) or NSNumber
@property (strong, nonatomic) NSObject *exp2; // either NSDictionary (variable) or NSString (constant) or NSNumber

+ (id)emptyExpression;
- (id)initWithJSON:(NSDictionary *)json;
- (NSString *)exp1stringValue;
- (NSString *)exp2stringValue;
- (NSDictionary *) JSONObject;

@end