#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"


typedef NS_ENUM(NSInteger, ZSCodeNewStatementType)
{
    ZSCodeNewStatementInsideOnEvent,
    ZSCodeNewStatementInsideIf,
    ZSCodeNewStatementTopLevel
};

@interface ZSCodeNewStatement : ZSCodeStatement

- (id) initWithSuite:(ZSCodeSuite *)suite;
- (ZSCodeNewStatementType) type;

@end
