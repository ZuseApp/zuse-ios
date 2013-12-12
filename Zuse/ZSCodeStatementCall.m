#import "ZSCodeStatementCall.h"
#import "ZSCodeLine.h"

@implementation ZSCodeStatementCall

+(id)emptyWithParentSuite:(ZSCodeSuite *)suite
{
    ZSCodeStatementCall *s = [[ZSCodeStatementCall alloc]initWithParentSuite:suite];
    s.methodName = @"move";
    s.params = @[@45, @200];
    return s;
}

- (id)initWithJSON:(NSDictionary *)json
       parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super initWithParentSuite:suite])
    {
        self.methodName = json[@"call"][@"method"];
        self.params = json[@"call"][@"parameters"];
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"call" : @{@"method" : self.methodName, @"parameters" : self.params}};
}

@end
