#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeStatementOnEvent : ZSCodeStatement

@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSMutableArray *parameters;
@property (strong, nonatomic) ZSCodeSuite *code;

@end
