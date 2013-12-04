#import <Foundation/Foundation.h>
#import "ZSCodeSuite.h"

@interface ZSCodeObject : NSObject

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) ZSCodeSuite *code;

+(id) codeObjectWithJSON:(NSDictionary *)json; // creates ZSCodeObject based on given json

-(NSArray *) codeLines; // forms an array of code lines
-(NSDictionary *) JSONObject; // forms JSON that represents this ZSCodeObject

@end
