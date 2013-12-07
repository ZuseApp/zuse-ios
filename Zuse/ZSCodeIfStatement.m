#import "ZSCodeIfStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeIfStatement()
@end

@implementation ZSCodeIfStatement

+(id)emptyStatementWithParentSuite:(ZSCodeSuite *)suite
{
    ZSCodeBoolExpression *boolExp = [ZSCodeBoolExpression expressionWithOper:@"=="
                                                                        exp1:@"..."
                                                                        exp2:@"..."];
    ZSCodeIfStatement *s = [[ZSCodeIfStatement alloc]initWithBoolExp: boolExp
                                                           trueSuite: nil
                                                          falseSuite: nil
                                                         parentSuite: suite];    
    s.trueSuite = [[ZSCodeSuite alloc]initWithParent:s
                                    indentationLevel:suite.indentationLevel + 1];
    return s;
}

-(id)initWithBoolExp:(ZSCodeBoolExpression*)boolExp
           trueSuite:(ZSCodeSuite *)trueSuite
          falseSuite:(ZSCodeSuite *)falseSuite
         parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        self.boolExp = boolExp;
        self.trueSuite = trueSuite;
        self.trueSuite.parentStatement = self;
        self.falseSuite = falseSuite;
        self.falseSuite.parentStatement = self;
        self.parentSuite = suite;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json
      parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super init])
    {
        self.boolExp = [ZSCodeBoolExpression expressionWithJSON:json[@"if"][@"test"]];
        self.trueSuite  = [[ZSCodeSuite alloc] initWithJSON:json[@"if"][@"true"]
                                                     parent:self
                                    indentationLevel:suite.indentationLevel + 1];
        self.falseSuite = [[ZSCodeSuite alloc] initWithJSON:json[@"if"][@"false"]
                                                     parent:self
                                    indentationLevel:suite.indentationLevel + 1];
        self.parentSuite = suite;
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"if" : @{@"test":@{}, @"true": self.trueSuite.JSONObject}};
}


@end
