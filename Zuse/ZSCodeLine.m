#import "ZSCodeLine.h"

@implementation ZSCodeLine

+(id)lineWithType: (ZSCodeStatementType)type
        statement: (ZSCodeStatement *)statement;
{
    ZSCodeLine *line = [[ZSCodeLine alloc]init];
    line.type = type;
    line.statement = statement;
    return line;
}

@end
