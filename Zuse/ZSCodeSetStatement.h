#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeCallStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeSetStatement : ZSCodeStatement

+(id)statementWithVariableName:(NSString *)name
                         value:(NSObject *)value
                         level:(NSInteger)level;
+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;

@end
