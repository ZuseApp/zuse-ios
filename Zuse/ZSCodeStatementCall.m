#import "ZSCodeStatementCall.h"
#import "ZSCodeLine.h"

@implementation ZSCodeStatementCall

+(id)emptyWithParentSuite:(ZSCodeSuite *)suite
{
    ZSCodeStatementCall *s = [[ZSCodeStatementCall alloc]initWithParentSuite:suite];
    s.methodName = @"...";
    s.args = [[NSMutableArray alloc]init];
    return s;
}

- (id)initWithJSON:(NSDictionary *)json
       parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super initWithParentSuite:suite])
    {
        self.methodName = json[@"call"][@"method"];
        self.args = json[@"call"][@"args"];
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"call" : @[self.methodName, self.args]};
}

@end
