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
        self.indentationLevel = level;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json
            level:(NSInteger)level
{
    if (self = [super init])
    {
        self.indentationLevel = level;
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
    ZSCodeLine *ifLine = [ZSCodeLine lineWithType:ZSCodeLineStatementIf
                                      indentation:self.indentationLevel
                                        statement:self];
    
    NSMutableArray *lines = [[NSMutableArray alloc]init];
    [lines addObject:ifLine];
    [lines addObjectsFromArray: self.trueSuite.codeLines];
        
    if(self.falseSuite)
    {
        ZSCodeLine *elseLine = [ZSCodeLine lineWithType:ZSCodeLineStatementDefault
                                            indentation:self.indentationLevel
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
