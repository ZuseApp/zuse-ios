#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"
#import "ZSCodeBoolExpression.h"

@interface ZSCodeIfStatement : ZSCodeStatement

+(id)statementWithBoolExp:(ZSCodeBoolExpression*)boolExp
                trueSuite:(ZSCodeSuite *)trueSuite
               falseSuite:(ZSCodeSuite *)falseSuite
                    level:(NSInteger)level;
+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;
@end
