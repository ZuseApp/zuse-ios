#import "ZSCodeObject.h"

@interface ZSCodeObject()

@end

@implementation ZSCodeObject

- (id) initWithJSON:(NSDictionary *)json
{
    if (self = [super init])
    {
        self.ID = json[@"id"];
        self.properties = [NSDictionary dictionaryWithDictionary:json[@"properties"]];
        self.code = [[ZSCodeSuite alloc] initWithJSON:json[@"code"]
                                               parent:self
                                     indentationLevel:0];
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
