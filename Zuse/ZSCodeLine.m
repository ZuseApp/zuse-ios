#import "ZSCodeLine.h"

NSString *const IF_STATEMENT_TYPE = @"IF";
NSString *const CALL_STATEMENT_TYPE = @"CALL";
NSString *const SET_STATEMENT_TYPE = @"SET";
NSString *const NEW_STATEMENT_TYPE = @"NEW";
NSString *const DEFAULT_STATEMENT_TYPE = @"DEFAULT";

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
