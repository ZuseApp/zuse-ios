#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeSuite : NSObject

@property (strong,  nonatomic) NSMutableArray   *statements;
@property (weak,    nonatomic) ZSCodeStatement  *parentStatement;

+(id) suiteWithJSON:(NSArray *)JSONSuite
             parent:(ZSCodeStatement *)parentStatement;
-(void) addStatement:(ZSCodeStatement *)statement;
-(NSArray *) codeLines;
-(NSArray *) JSONObject;

@end
