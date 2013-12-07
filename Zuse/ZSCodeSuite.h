#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeLine.h"

@class ZSCodeStatement;

@interface ZSCodeSuite : NSObject

@property (strong, nonatomic) NSMutableArray *statements;
@property (weak, nonatomic) ZSCodeStatement *parentStatement;
@property (nonatomic) NSInteger indentationLevel;


- (id) initWithParent: (ZSCodeStatement *) parentStatement
     indentationLevel: (NSInteger)level;

- (id) initWithJSON: (NSArray *) JSONSuite
             parent: (ZSCodeStatement *) parentStatement
   indentationLevel: (NSInteger)level;



- (void) addStatement: (ZSCodeStatement *) statement;
- (void) addEmptyStatementWithType: (ZSCodeStatementType)type;
- (NSArray *) codeLines;
- (NSArray *) JSONObject;

@end
