#import <Foundation/Foundation.h>

@interface ZSCodeObject : NSObject

+(id) codeObjectWithJSON:(NSDictionary *)json;

-(NSArray *) codeLines;
-(NSDictionary *) JSONObject;

@end
