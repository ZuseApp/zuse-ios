
#import "ZSCodeCallStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeCallStatement()

@end

@implementation ZSCodeCallStatement

- (id)initWithMethodName:(NSString *)name
                    args:(NSMutableArray *)args
             parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        self.methodName = name;
        self.args = args;
        self.parentSuite = suite;
    }
    return self;
}

- (id)initWithJSON:(NSDictionary *)json
       parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        self.methodName = json[@"call"][@"method"];
        self.args = json[@"call"][@"args"];
        self.parentSuite = suite;
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"call" : @[self.methodName, self.args]};
}

@end
