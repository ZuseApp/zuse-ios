
#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeStatementCall : ZSCodeStatement

@property (strong, nonatomic) NSString *methodName;
@property (strong, nonatomic) NSMutableArray *args;

@end



