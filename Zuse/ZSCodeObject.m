#import "ZSCodeObject.h"

@interface ZSCodeObject()

@end

@implementation ZSCodeObject

+(id) codeObjectWithJSON:(NSDictionary *)json
{
    ZSCodeObject *obj = [[ZSCodeObject alloc]init];
    
    obj.ID = json[@"id"];
    obj.properties = [NSDictionary dictionaryWithDictionary:json[@"properties"]];
    obj.code = [ZSCodeSuite suiteWithJSON:json[@"code"]
                                   parent:nil
                         indentationLevel:0];
    return obj;
}
-(NSArray *) codeLines
{
    return self.code.codeLines;
}

-(NSDictionary *) JSONObject
{
    return @{@"id":self.ID, @"properties":self.properties, @"code":self.code.JSONObject};
}

@end
