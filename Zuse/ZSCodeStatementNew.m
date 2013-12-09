#import "ZSCodeStatementNew.h"
#import "ZSCodeStatementSet.h"
#import "ZSCodeStatementIf.h"
#import "ZSCodeStatementCall.h"
#import "ZSCodeStatementOnEvent.h"
#import "ZSCodeStatementObject.h"

@implementation ZSCodeStatementNew

- (id)initWithParentSuite: (ZSCodeSuite *)s
{
    if (self = [super initWithParentSuite:s])
    {
        ZSCodeStatement *parentStatement = self.parentSuite.parentStatement;
        
        if ([parentStatement isKindOfClass:[ZSCodeStatementIf class]])
        {
            self.parentCodeStatementType = ZSCodeStatementTypeIf;
        }
        else if ([parentStatement isKindOfClass:[ZSCodeStatementOnEvent class]])
        {
            self.parentCodeStatementType = ZSCodeStatementTypeOnEvent;
        }
        else if ([parentStatement isKindOfClass:[ZSCodeStatementObject class]])
        {
            self.parentCodeStatementType = ZSCodeStatementTypeObject;
        }
        else
            @throw @"ZSCodeNewStatement: parentSuite has invalid parentStatement";
    }
    return self;
}

@end
