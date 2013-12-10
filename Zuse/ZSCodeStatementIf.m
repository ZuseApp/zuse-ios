#import "ZSCodeStatementIf.h"
#import "ZSCodeLine.h"

@implementation ZSCodeStatementIf

+(id)emptyWithParentSuite:(ZSCodeSuite *)suite
{
    ZSCodeStatementIf *s = [[ZSCodeStatementIf alloc]initWithParentSuite:suite];
    s.boolExp = [ZSCodeBoolExpression emptyExpression];
    s.trueSuite = [[ZSCodeSuite alloc]initWithParentStatement:s];
    return s;
}

-(id)initWithJSON:(NSDictionary *)json
      parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super initWithParentSuite:suite])
    {
        self.boolExp = [[ZSCodeBoolExpression alloc ]initWithJSON: json[@"if"][@"test"]];
        self.trueSuite  = [[ZSCodeSuite alloc] initWithJSON: json[@"if"][@"true"]
                                            parentStatement: self];
        self.falseSuite = [[ZSCodeSuite alloc] initWithJSON: json[@"if"][@"false"]
                                            parentStatement: self];
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"if" : @{@"test":@{}, @"true": self.trueSuite.JSONObject}};
}

@end


@implementation ZSCodeBoolExpression

+ (id)emptyExpression
{
    ZSCodeBoolExpression *e = [[ZSCodeBoolExpression alloc]init];
    e.sign = @"==";
    e.exp1 = @"...";
    e.exp2 = @"...";
    return e;
}

- (id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init])
    {
        self.sign = [json allKeys][0];
        self.exp1 = json[self.sign][0];
        self.exp2 = json[self.sign][1];
    }
    return self;
}

- (NSString *)exp1stringValue
{
    return [self convertToStringExpression:self.exp1];
}

- (NSString *)exp2stringValue
{
    return [self convertToStringExpression:self.exp2];
}

+(BOOL)isBooleanType:(NSNumber *)n
{
    return strcmp([n objCType], @encode(BOOL)) == 0;
}

-(NSString *)convertToStringExpression:(NSObject *)exp
{
    NSString *str;
    
    // if it is get statement
    if ([exp isKindOfClass:[NSDictionary class]])
    {
        str = ((NSDictionary *)exp)[@"get"];
    }
    // if it is number
    else if ([exp isKindOfClass:[NSNumber class]])
    {
        NSNumber *n = (NSNumber *)exp;
        str = [ZSCodeBoolExpression isBooleanType:n] ? ([n integerValue] ? @"true" : @"false") : [n stringValue];
    }
    // if it is constant (string)
    else
        str = (NSString *)exp;
    
    return str;
}

@end