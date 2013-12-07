#import "ZSCodeNewStatement.h"
#import "ZSCodeSetStatement.h"
#import "ZSCodeIfStatement.h"
#import "ZSCodeCallStatement.h"
#import "ZSCodeOnEventStatement.h"

@implementation ZSCodeNewStatement

- (id) initWithSuite: (ZSCodeSuite *) suite
{
    if (self = [super init])
    {
        self.parentSuite = suite;
    }
    return self;
}

- (ZSCodeNewStatementType) type
{
    if ([self.parentSuite.parentStatement isKindOfClass:[ZSCodeIfStatement class]])
    {
        return ZSCodeNewStatementInsideIf;
    }
    else if ([self.parentSuite.parentStatement isKindOfClass:[ZSCodeOnEventStatement class]])
    {
        return ZSCodeNewStatementInsideOnEvent;
    }
    else
    {
        return ZSCodeNewStatementTopLevel;
    }
}

@end
