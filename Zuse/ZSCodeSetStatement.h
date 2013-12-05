#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeCallStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeSetStatement : ZSCodeStatement

@property (strong, nonatomic) NSString *variableName;
@property (strong, nonatomic) NSObject *variableValue; // either NSString, or NSNumber, or ZSCodeCallStatement, or NSDictionary (get)


- (id) initWithVariableName:(NSString *)name
                      value:(NSObject *)value
                parentSuite:(ZSCodeSuite *)suite;
- (id) initWithJSON:(NSDictionary *)json
        parentSuite:(ZSCodeSuite *)suite;

- (NSString *)variableValueStringValue;

@end
