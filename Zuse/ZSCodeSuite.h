#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeSuite : NSObject

@property (strong, nonatomic) NSMutableArray *statements;
@property (nonatomic) NSInteger level;
@property (weak, nonatomic) ZSCodeStatement *parentStatement;

+(id) suiteWithJSON:(NSArray *)JSONSuite
              level:(NSInteger)level
             parent:(ZSCodeStatement *)parentStatement;
-(void) addStatement:(ZSCodeStatement *)statement;
-(NSArray *) codeLines;
-(NSArray *) JSONObject;

@end
