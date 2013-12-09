#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeStatementCall.h"
#import "ZSCodeSuite.h"

@interface ZSCodeStatementSet : ZSCodeStatement

@property (strong, nonatomic) NSString *variableName;
@property (strong, nonatomic) NSObject *variableValue; // either NSString, or NSNumber, or ZSCodeCallStatement, or NSDictionary (get)

- (NSString *)variableValueStringValue;

@end
