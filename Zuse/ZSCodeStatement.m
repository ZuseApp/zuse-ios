#import "ZSCodeStatement.h"
#import "ZSCodeOnEventStatement.h"
#import "ZSCodeSetStatement.h"
#import "ZSCodeObject.h"

@implementation ZSCodeStatement

-(NSDictionary *) JSONObject
{
    @throw @"ZSCodeStatement: JSONObject should be overridden in subclasses";
    return nil;
}

- (NSArray *) availableVarNames
{
    NSMutableArray *varNames = [[NSMutableArray alloc]init];
    
    for (ZSCodeStatement *s in self.parentSuite.statements)
    {
        if (s == self)
        {
            break;
        }
        // 'SET' statement
        if ([s isKindOfClass:[ZSCodeSetStatement class]])
        {
            [varNames addObject:((ZSCodeSetStatement *)s).variableName];
        }
    }
    
    // If inside ON EVENT statement
    if( [self.parentSuite.parentStatement isKindOfClass: [ZSCodeOnEventStatement class]])
    {
        [varNames addObjectsFromArray:((ZSCodeOnEventStatement *)self.parentSuite.parentStatement).parameters];
    }

    [varNames addObjectsFromArray:self.parentSuite.parentStatement.availableVarNames];
    
    return varNames;
}
@end
