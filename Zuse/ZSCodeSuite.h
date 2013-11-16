#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeSuite : ZSCodeStatement

-(id)initWithLevel:(NSInteger)level;
+(id)suiteWithJSON:(NSArray *)JSONSuite
             level:(NSInteger)level;
-(void) addStatement:(ZSCodeStatement *)statement;

@end
