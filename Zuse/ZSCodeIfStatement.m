#import "ZSCodeIfStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeIfStatement()
@end

@implementation ZSCodeIfStatement


-(id)initWithBoolExp:(ZSCodeBoolExpression*)boolExp
           trueSuite:(ZSCodeSuite *)trueSuite
          falseSuite:(ZSCodeSuite *)falseSuite
               level:(NSInteger)level
{
    if (self = [super init])
    {
        self.boolExp = boolExp;
        self.trueSuite = trueSuite;
        self.trueSuite.parentStatement = self;
        self.falseSuite = falseSuite;
        self.falseSuite.parentStatement = self;
        self.level = level;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json
            level:(NSInteger)level
{
    if (self = [super init])
    {
        self.level = level;
        self.boolExp = [ZSCodeBoolExpression expressionWithJSON:json[@"if"][@"test"]];
        self.trueSuite = [ZSCodeSuite suiteWithJSON:json[@"if"][@"true"]
                                             parent:self];
        self.falseSuite = [ZSCodeSuite suiteWithJSON:json[@"if"][@"false"]
                                              parent:self];
    }
    return self;
}

-(NSArray *) codeLines
{
    ZSCodeLine *ifLine = [ZSCodeLine lineWithText:[NSString stringWithFormat:@"IF %@", self.boolExp.stringValue]
                                             type:ZSCodeLineStatementIf
                                      indentation:self.level
                                        statement:self];
    
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    [lines addObject:ifLine];
    [lines addObjectsFromArray: self.trueSuite.codeLines];
        
    if(self.falseSuite)
    {
        ZSCodeLine *elseLine = [ZSCodeLine lineWithText:@"ELSE"
                                                   type:ZSCodeLineStatementDefault
                                            indentation:self.level
                                              statement:self];
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
