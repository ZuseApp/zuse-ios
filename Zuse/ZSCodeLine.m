#import "ZSCodeLine.h"

NSString *const ZSCodeLineStatementIf = @"IF";
NSString *const ZSCodeLineStatementCall = @"CALL";
NSString *const ZSCodeLineStatementSet = @"SET";
NSString *const ZSCodeLineStatementOnEvent = @"ON EVENT";
NSString *const ZSCodeLineStatementNew = @"NEW";
NSString *const ZSCodeLineStatementDefault = @"DEFAULT";

@implementation ZSCodeLine

+(id)lineWithType: (NSString *)type // see constants above
      indentation: (NSInteger)indentation
        statement: (ZSCodeStatement *)statement;
{
    ZSCodeLine *line = [[ZSCodeLine alloc]init];
    line.type = type;
    line.indentation = indentation;
    line.statement = statement;
    return line;
}

@end
