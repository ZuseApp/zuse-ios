#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeOnEventStatement : ZSCodeStatement

+(id)statementWith:(NSString *)name
        parameters:(NSMutableArray *)params
              code:(ZSCodeSuite *)code;

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;
@end
