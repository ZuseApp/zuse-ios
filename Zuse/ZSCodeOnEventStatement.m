#import "ZSCodeOnEventStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeOnEventStatement()

@end

@implementation ZSCodeOnEventStatement


+(id)statementWithName:(NSString *)name
            parameters:(NSMutableArray *)params
                  code:(ZSCodeSuite *)code
{
    ZSCodeOnEventStatement *s = [[ZSCodeOnEventStatement alloc]init];
    s.eventName = name;
    s.parameters = params;
    s.code = code;
    s.code.parentStatement = s;
    return s;
}

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    return [self statementWithName:json[@"on_event"][@"name"]
                        parameters:json[@"on_event"][@"parameters"]
                              code:[ZSCodeSuite suiteWithJSON:json[@"on_event"][@"code"]
                                                    level:level+1
                                                   parent:nil]];
}

-(NSArray *) codeLines
{
    ZSCodeLine *onEventLine = [ZSCodeLine lineWithText:[NSString stringWithFormat:@"ON EVENT: %@", self.eventName]
                                                  type:ZSCodeLineStatementOnEvent
                                           indentation:self.level
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
