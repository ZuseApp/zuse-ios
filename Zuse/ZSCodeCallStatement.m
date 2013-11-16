//
//  ZSCodeCallStatement.m
//  Code Editor 2
//
//  Created by Vladimir on 10/22/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//

#import "ZSCodeCallStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeCallStatement()
-(NSString *) argsAsString;
-(void)updateCodeLines;
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
    [s updateCodeLines];
    return s;
}

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    return [self statementWithMethodName:json[@"call"][@"method"]
                                    args:json[@"call"][@"args"]
                                   level:level];
}

-(void)updateCodeLines
{
    NSString *text = [NSString stringWithFormat:@"%@: %@",self.methodName, [self argsAsString]];
    ZSCodeLine *line = [ZSCodeLine lineWithText:text
                                           type:CALL_STATEMENT_TYPE
                                    indentation:self.level];
    self.codeLines[0] = line;
}

// helper method for text method
-(NSString *) argsAsString
{
    NSMutableString *argList = [NSMutableString stringWithString:@""];
    for (NSString *arg in self.args)
    {
        [argList appendFormat:@"%@,", arg];
    }
    return [argList substringToIndex:argList.length-1]; // delete last comma
}

@end
