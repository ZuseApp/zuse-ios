#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"
#import "ZSCodeBoolExpression.h"

@interface ZSCodeIfStatement : ZSCodeStatement

@property (strong, nonatomic) ZSCodeBoolExpression *boolExp;
@property (strong, nonatomic) ZSCodeSuite *trueSuite;
@property (strong, nonatomic) ZSCodeSuite *falseSuite;

-(id)initWithBoolExp:(ZSCodeBoolExpression*)boolExp
           trueSuite:(ZSCodeSuite *)trueSuite
          falseSuite:(ZSCodeSuite *)falseSuite
         parentSuite:(ZSCodeSuite *)suite;
-(id)initWithJSON:(NSDictionary *)json
      parentSuite:(ZSCodeSuite *)suite;  

@end
