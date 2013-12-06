#import <Foundation/Foundation.h>


@class ZSCodeStatement;

@interface ZSCodeSuite : NSObject

@property (strong, nonatomic) NSMutableArray *statements;
@property (weak, nonatomic) ZSCodeStatement *parentStatement;
@property (nonatomic) NSInteger indentationLevel;

-(id) initWithJSON: (NSArray *) JSONSuite
            parent: (ZSCodeStatement *) parentStatement
  indentationLevel: (NSInteger)level;

- (void) addStatement:(ZSCodeStatement *) statement;
- (void) addEmptySetStatement;
- (NSArray *) codeLines;
- (NSArray *) JSONObject;

@end
