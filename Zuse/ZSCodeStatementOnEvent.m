#import "ZSCodeStatementOnEvent.h"
#import "ZSCodeLine.h"

@implementation ZSCodeStatementOnEvent

+(id)emptyWithParentSuite:(ZSCodeSuite *)suite
{
    ZSCodeStatementOnEvent *s = [[ZSCodeStatementOnEvent alloc]initWithParentSuite:suite];
    s.eventName = @"...";
    s.parameters = [[NSMutableArray alloc]init];
    s.code = [[ZSCodeSuite alloc]initWithParentStatement:s];
    return s;
}

-(id)initWithJSON:(NSDictionary *)json
      parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super initWithParentSuite:suite])
    {
        self.eventName = json[@"on_event"][@"name"];
        self.parameters = json[@"on_event"][@"parameters"];
        self.code = [[ZSCodeSuite alloc] initWithJSON:json[@"on_event"][@"code"]
                                      parentStatement:self];
        self.code.parentStatement = self;
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"on_event" : @{@"name":self.eventName, @"parameters": self.parameters, @"code":self.code.JSONObject}};
}

@end
