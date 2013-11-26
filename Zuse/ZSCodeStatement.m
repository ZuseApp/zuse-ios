#import "ZSCodeStatement.h"

@implementation ZSCodeStatement

-(id)init
{
    if (self = [super init])
    {
        self.level = 0;
    }
    return self;
}

-(NSDictionary *) JSONObject {
    @throw @"ZSCodeStatement: JSONObject should be overridden in subclasses";
    return nil;
}

-(NSArray *) codeLines {
    @throw @"ZSCodeStatement: JSONObject should be overridden in subclasses";
    return nil;
}

@end
