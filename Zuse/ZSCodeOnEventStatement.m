#import "ZSCodeOnEventStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeOnEventStatement()

@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSMutableArray *parameters;
@property (strong, nonatomic) ZSCodeSuite *code;

@end

@implementation ZSCodeOnEventStatement


+(id)statementWith:(NSString *)name
        parameters:(NSMutableArray *)params
              code:(ZSCodeSuite *)code
{
    ZSCodeOnEventStatement *s = [[ZSCodeOnEventStatement alloc]init];
    s.eventName = name;
    s.parameters = params;
    s.code = code;
    return s;
}

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    return [self statementWith:json[@"on_event"][@"name"]
                    parameters:json[@"on_event"][@"parameters"]
                          code:[ZSCodeSuite suiteWithJSON:json[@"on_event"][@"code"]
                                                    level:level+1]];
}

-(NSArray *) codeLines
{
    ZSCodeLine *onEventLine = [ZSCodeLine lineWithText:[NSString stringWithFormat:@"ON EVENT: %@", self.eventName]
                                                  type:ZSCodeLineStatementOnEvent
                                           indentation:self.level];
    
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    [lines addObject:onEventLine];
    [lines addObjectsFromArray: self.code.codeLines];    
    return lines;
}


-(void)updateCodeLines
{

}

-(NSDictionary *) JSONObject
{
    return @{@"on_event" : @{@"name":self.eventName, @"parameters": self.parameters, @"code":[self.code JSONObject]}};
}

@end
