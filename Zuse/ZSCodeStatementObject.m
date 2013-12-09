#import "ZSCodeStatementObject.h"

@implementation ZSCodeStatementObject

- (id)initWithJSON:(NSDictionary *)json
       parentSuite:(ZSCodeSuite *)suite
{
    if (self = [super initWithParentSuite:suite])
    {
        self.ID = json[@"id"];
        self.properties = [NSDictionary dictionaryWithDictionary:json[@"properties"]];
        self.code = [[ZSCodeSuite alloc] initWithJSON:json[@"code"]
                                      parentStatement:self];
    }
    return self;
}

-(NSDictionary *) JSONObject
{
    return @{@"id":self.ID, @"properties":self.properties, @"code":self.code.JSONObject};
}

- (NSArray *) availableVarNames
{
    return [self.properties allKeys];
}

@end
