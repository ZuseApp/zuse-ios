#import "ZSCodeOnEventStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeOnEventStatement()

@end

@implementation ZSCodeOnEventStatement


-(id)initWithName:(NSString *)name
       parameters:(NSMutableArray *)params
             code:(ZSCodeSuite *)code
{
    if (self = [super init])
    {
        self.eventName = name;
        self.parameters = params;
        self.code = code;
        self.code.parentStatement = self;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    if (self = [super init])
    {
        self.eventName = json[@"on_event"][@"name"];
        self.parameters = json[@"on_event"][@"parameters"];
        self.code = [ZSCodeSuite suiteWithJSON:json[@"on_event"][@"code"]
                                        parent:self];
        self.code.parentStatement = self;
    }
    return self;
}

-(NSArray *) codeLines
{
    ZSCodeLine *onEventLine = [ZSCodeLine lineWithType:ZSCodeLineStatementOnEvent
                                           indentation:self.indentationLevel
                                             statement:self];
    
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    [lines addObject:onEventLine];
    [lines addObjectsFromArray: self.code.codeLines];    
    return lines;
}

-(NSDictionary *) JSONObject
{
    return @{@"on_event" : @{@"name":self.eventName, @"parameters": self.parameters, @"code":self.code.JSONObject}};
}

@end
