#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeOnEventStatement : ZSCodeStatement

@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSMutableArray *parameters;
@property (strong, nonatomic) ZSCodeSuite *code;

+(id)statementWithName:(NSString *)name
            parameters:(NSMutableArray *)params
                  code:(ZSCodeSuite *)code;

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;
@end
