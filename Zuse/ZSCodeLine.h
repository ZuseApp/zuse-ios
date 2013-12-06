#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

extern NSString *const ZSCodeLineStatementIf;
extern NSString *const ZSCodeLineStatementCall;
extern NSString *const ZSCodeLineStatementSet;
extern NSString *const ZSCodeLineStatementOnEvent;
extern NSString *const ZSCodeLineStatementNew;
extern NSString *const ZSCodeLineStatementDefault;

@interface ZSCodeLine : NSObject

@property (strong, nonatomic) NSString *type;
@property (nonatomic) NSInteger indentation;
@property (strong, nonatomic) ZSCodeStatement *statement;

+(id)lineWithType:(NSString *)type
      indentation:(NSInteger)indentation
        statement:(ZSCodeStatement *)statement;
@end
