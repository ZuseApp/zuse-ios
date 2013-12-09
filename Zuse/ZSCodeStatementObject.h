#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeStatementObject : ZSCodeStatement

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) ZSCodeSuite *code;

@end
