#import "ZSCodeOnEventStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeOnEventStatement()

@end

@implementation ZSCodeOnEventStatement

-(id)initWithName:(NSString *)name
       parameters:(NSMutableArray *)params
             code:(ZSCodeSuite *)code
      parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        self.eventName = name;
        self.parameters = params;
        self.code = code;
        self.code.parentStatement = self;
        self.parentSuite = suite;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json
      parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        self.eventName = json[@"on_event"][@"name"];
        self.parameters = json[@"on_event"][@"parameters"];
        self.code = [ZSCodeSuite suiteWithJSON:json[@"on_event"][@"code"]
                                        parent:self
                              indentationLevel:suite.indentationLevel + 1];
        self.code.parentStatement = self;
        self.parentSuite = suite;
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"on_event" : @{@"name":self.eventName, @"parameters": self.parameters, @"code":self.code.JSONObject}};
}

@end
