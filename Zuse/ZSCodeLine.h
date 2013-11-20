#import <Foundation/Foundation.h>

extern NSString *const ZSCodeLineStatementIf;
extern NSString *const ZSCodeLineStatementCall;
extern NSString *const ZSCodeLineStatementSet;
extern NSString *const ZSCodeLineStatementOnEvent;
extern NSString *const ZSCodeLineStatementNew;
extern NSString *const ZSCodeLineStatementDefault;

@interface ZSCodeLine : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *type;
@property (nonatomic) NSInteger indentation;

+(id)lineWithText:(NSString *)text
             type:(NSString *)type
      indentation:(NSInteger)idnent;
@end
