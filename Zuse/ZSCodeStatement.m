#import "ZSCodeStatement.h"
#import "ZSCodeStatementOnEvent.h"
#import "ZSCodeStatementSet.h"
#import "ZSCodeStatementObject.h"

@implementation ZSCodeStatement

- (id)initWithParentSuite: (ZSCodeSuite *)s
{
    if (self = [super init])
    {
        self.parentSuite = s;
    }
    return self;
}

- (NSArray *) availableVarNames
{
    NSMutableSet *varNames = [[NSMutableSet alloc]init];
    
    for (ZSCodeStatement *s in self.parentSuite.statements)
    {
        if (s == self)
        {
            break;
        }
        // 'SET' statement that does not have '...' as variable name
        if ([s isKindOfClass:[ZSCodeStatementSet class]] && ![((ZSCodeStatementSet *)s).variableName isEqualToString:@"..."])
        {
            [varNames  addObject:((ZSCodeStatementSet *)s).variableName];
        }
    }
    
    // If inside ON EVENT statement
    if( [self.parentSuite.parentStatement isKindOfClass: [ZSCodeStatementOnEvent class]])
    {
        [varNames addObjectsFromArray:((ZSCodeStatementOnEvent *)self.parentSuite.parentStatement).parameters];
    }
    
    // add from parent statement
    [varNames addObjectsFromArray:self.parentSuite.parentStatement.availableVarNames];
    
    return [varNames sortedArrayUsingDescriptors:nil];
}

#pragma mark - Messages to be implemented in subclass

+ (id)emptyWithParentSuite:(ZSCodeSuite *)suite
{
    @throw @"ZSCodeStatement: [emptyStatementWithParentSuite:] should be overridden in subclasses";
    return nil;
}
- (id)initWithJSON:(NSDictionary *)json
       parentSuite:(ZSCodeSuite *)suite
{
    @throw @"ZSCodeStatement: [initWithJSON: parentSuite:] should be overridden in subclasses";
    return nil;
}
- (NSDictionary *) JSONObject
{
    @throw @"ZSCodeStatement: [JSONObject] should be overridden in subclasses";
    return nil;
}

@end
