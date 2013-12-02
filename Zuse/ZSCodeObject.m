#import "ZSCodeObject.h"
#import "ZSCodeSuite.h"

@interface ZSCodeObject()

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) ZSCodeSuite *code;

@end

@implementation ZSCodeObject

+(id) codeObjectWithJSON:(NSDictionary *)json
{
    ZSCodeObject *obj = [[ZSCodeObject alloc]init];
    
    obj.ID = json[@"id"];
    obj.properties = [NSDictionary dictionaryWithDictionary:json[@"properties"]];
    obj.code = [ZSCodeSuite suiteWithJSON:json[@"code"]
                                    level:0
                                   parent:nil];
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
