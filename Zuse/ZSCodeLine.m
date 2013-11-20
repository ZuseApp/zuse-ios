#import "ZSCodeLine.h"

NSString *const ZSCodeLineStatementIf = @"IF";
NSString *const ZSCodeLineStatementCall = @"CALL";
NSString *const ZSCodeLineStatementSet = @"SET";
NSString *const ZSCodeLineStatementOnEvent = @"ON EVENT";
NSString *const ZSCodeLineStatementNew = @"NEW";
NSString *const ZSCodeLineStatementDefault = @"DEFAULT";

@implementation ZSCodeLine

+(id)lineWithText:(NSString *)text
             type:(NSString *)type
      indentation:(NSInteger)indentation
{
    ZSCodeLine *line = [[ZSCodeLine alloc]init];
    line.text = text;
    line.type = type;
    line.indentation = indentation;
    return line;
}

@end
