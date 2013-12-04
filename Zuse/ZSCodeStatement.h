#import <Foundation/Foundation.h>

@interface ZSCodeStatement : NSObject

@property (nonatomic) NSInteger indentationLevel;

-(NSDictionary *) JSONObject;
-(NSArray *) codeLines;

@end
