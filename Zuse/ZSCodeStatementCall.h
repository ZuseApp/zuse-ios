
#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeStatementCall : ZSCodeStatement

@property (strong, nonatomic) NSString *methodName;
@property (strong, nonatomic) NSArray *params;

@end



