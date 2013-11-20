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
                                    level:0];
    return obj;
}
-(NSArray *) codeLines
{
    return self.code.codeLines;
}

-(NSArray *) JSONObject
{
    return nil;
}

@end