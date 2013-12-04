#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeOnEventStatement : ZSCodeStatement

@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSMutableArray *parameters;
@property (strong, nonatomic) ZSCodeSuite *code;

-(id)initWithName:(NSString *)name
            parameters:(NSMutableArray *)params
                  code:(ZSCodeSuite *)code;

-(id)initWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;

@end
