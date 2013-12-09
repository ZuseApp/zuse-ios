#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeLine.h"

@interface ZSCodeSuite : NSObject

@property (strong, nonatomic) NSMutableArray *statements;
@property (weak, nonatomic) ZSCodeStatement *parentStatement;

- (id) initWithParentStatement: (ZSCodeStatement *) s;
- (id) initWithJSON: (NSArray *)JSONSuite
    parentStatement: (ZSCodeStatement *)p;
- (NSArray *) codeLines;
- (NSArray *) JSONObject;



- (void) addStatement: (ZSCodeStatement *)statement;
- (void) addEmptyStatementWithType: (ZSCodeStatementType)type;
- (NSInteger) indentationLevel;
@end
