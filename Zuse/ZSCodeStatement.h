#import <Foundation/Foundation.h>

@interface ZSCodeStatement : NSObject

@property (nonatomic) NSInteger level;

-(id)init;
-(NSDictionary *) JSONObject;
-(NSArray *) codeLines;

@end
