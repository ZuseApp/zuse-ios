
#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeCallStatement : ZSCodeStatement

+(id)statementWithMethodName:(NSString *)name
                        args:(NSMutableArray *)args
                       level:(NSInteger)level;
+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;

@end



