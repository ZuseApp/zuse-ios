#import <Foundation/Foundation.h>

@interface ZSCodeStatement : NSObject

@property (nonatomic) NSInteger level;

-(NSDictionary *) JSONObject;
-(NSArray *) codeLines;

@end
