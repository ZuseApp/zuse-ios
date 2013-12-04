
#import "ZSCodeCallStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeCallStatement()

@end

@implementation ZSCodeCallStatement

+(id)statementWithMethodName:(NSString *)name
                        args:(NSMutableArray *)args
                       level:(NSInteger)level
{
    ZSCodeCallStatement *s = [[ZSCodeCallStatement alloc]init];
    s.methodName = name;
    s.args = args;
    s.indentationLevel = level;
    return s;
}

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    return [self statementWithMethodName:json[@"call"][@"method"]
                                    args:json[@"call"][@"args"]
                                   level:level];
}

-(NSArray *) codeLines
{
    // Create code line object
    ZSCodeLine *line = [ZSCodeLine lineWithType:ZSCodeLineStatementCall
                                    indentation:self.indentationLevel
                                      statement:self];
    // Put code line in array
    return [NSMutableArray arrayWithObject:line];
}

-(NSDictionary *) JSONObject
{
    return @{@"call" : @[self.methodName, self.args]};
}

@end
