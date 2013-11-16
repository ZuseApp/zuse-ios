#import "ZSCodeIfStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeIfStatement()
-(void)updateCodeLines;
@end

@implementation ZSCodeIfStatement

+(id)statementWithBoolExp:(ZSCodeBoolExpression*)boolExp
                trueSuite:(ZSCodeSuite *)trueSuite
               falseSuite:(ZSCodeSuite *)falseSuite
                    level:(NSInteger)level
{
    ZSCodeIfStatement *s = [[ZSCodeIfStatement alloc]init];
    s.boolExp = boolExp;
    s.trueSuite = trueSuite;
    s.falseSuite = falseSuite;
    s.level = level;
    [s updateCodeLines];
    return s;
}

+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level
{
    return [self statementWithBoolExp:[ZSCodeBoolExpression expressionWithJSON:json[@"if"][@"test"]]
                            trueSuite:[ZSCodeSuite suiteWithJSON:json[@"if"][@"true"]
                                                           level:level+1]
                           falseSuite:[ZSCodeSuite suiteWithJSON:json[@"if"][@"false"]
                                                           level:level+1]
                                level:level];
}

-(void)updateCodeLines
{
    ZSCodeLine *ifLine = [ZSCodeLine lineWithText:[NSString stringWithFormat:@"IF %@", self.boolExp.text]
                                             type:IF_STATEMENT_TYPE
                                      indentation:self.level];
    ZSCodeLine *elseLine = [ZSCodeLine lineWithText:@"ELSE"
                                               type:DEFAULT_STATEMENT_TYPE
                                        indentation:self.level];
    [self.codeLines removeAllObjects];
    [self.codeLines addObject:ifLine];
    [self.codeLines addObjectsFromArray: self.trueSuite.codeLines];
    [self.codeLines addObject:elseLine];
    [self.codeLines addObjectsFromArray: self.falseSuite.codeLines];
}

@end
