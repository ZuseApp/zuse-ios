
#import "ZSCodeCallStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeCallStatement()

@property (strong, nonatomic) NSString *methodName;
@property (strong, nonatomic) NSMutableArray *args;

@end

@implementation ZSCodeCallStatement

+(id)statementWithMethodName:(NSString *)name
                        args:(NSMutableArray *)args
                       level:(NSInteger)level
{
    ZSCodeCallStatement *s = [[ZSCodeCallStatement alloc]init];
    s.methodName = name;
    s.args = args;
    s.level = level;
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
    // Form text for arguments
    NSMutableString *argList = [NSMutableString stringWithString:@""];
    for (NSString *arg in self.args)
    {
        [argList appendFormat:@"%@,", arg];
    }
    NSString *textArgList = [argList substringToIndex:argList.length-1]; // delete last comma
    
    // Form text for code line
    NSString *text = [NSString stringWithFormat:@"%@: %@",self.methodName, textArgList];
    
    // Create code line object
    ZSCodeLine *line = [ZSCodeLine lineWithText:text
                                           type:ZSCodeLineStatementCall
                                    indentation:self.level];
    // Put code line in array
    return [NSMutableArray arrayWithObject:line];
}

-(NSDictionary *) JSONObject
{
    return @{@"call" : @[self.methodName, self.args]};
}

@end
