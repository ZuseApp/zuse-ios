#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeSuite : NSObject

+(id) suiteWithJSON:(NSArray *)JSONSuite
              level:(NSInteger)level;
-(void) addStatement:(ZSCodeStatement *)statement;
-(NSArray *) codeLines;
-(NSArray *) JSONObject;

@end
