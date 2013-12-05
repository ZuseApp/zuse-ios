#import "ZSCodeStatement.h"

@implementation ZSCodeStatement

-(NSDictionary *) JSONObject
{
    @throw @"ZSCodeStatement: JSONObject should be overridden in subclasses";
    return nil;
}

@end
