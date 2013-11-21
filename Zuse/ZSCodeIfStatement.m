#import "ZSCodeIfStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeIfStatement()

@property (strong, nonatomic) ZSCodeBoolExpression *boolExp;
@property (strong, nonatomic) ZSCodeSuite *trueSuite;
@property (strong, nonatomic) ZSCodeSuite *falseSuite;

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

-(NSArray *) codeLines
{
    ZSCodeLine *ifLine = [ZSCodeLine lineWithText:[NSString stringWithFormat:@"IF %@", self.boolExp.stringValue]
                                             type:ZSCodeLineStatementIf
                                      indentation:self.level];
    
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    [lines addObject:ifLine];
    [lines addObjectsFromArray: self.trueSuite.codeLines];
        
    if(self.falseSuite)
    {
        ZSCodeLine *elseLine = [ZSCodeLine lineWithText:@"ELSE"
                                                   type:ZSCodeLineStatementDefault
                                            indentation:self.level];
        [lines addObject:elseLine];
        [lines addObjectsFromArray: self.falseSuite.codeLines];
    }
    return lines;
}

-(NSDictionary *) JSONObject
{
    return @{@"if" : @{@"test":@{}, @"true": self.trueSuite.JSONObject}};
}


@end
