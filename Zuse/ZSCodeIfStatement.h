#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"
#import "ZSCodeBoolExpression.h"

@interface ZSCodeIfStatement : ZSCodeStatement

@property (strong, nonatomic) ZSCodeBoolExpression *boolExp;
@property (strong, nonatomic) ZSCodeSuite *trueSuite;
@property (strong, nonatomic) ZSCodeSuite *falseSuite;

+(id)statementWithBoolExp:(ZSCodeBoolExpression*)boolExp
                trueSuite:(ZSCodeSuite *)trueSuite
               falseSuite:(ZSCodeSuite *)falseSuite
                    level:(NSInteger)level;
+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;
@end
