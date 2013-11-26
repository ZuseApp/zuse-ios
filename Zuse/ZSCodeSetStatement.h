#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeCallStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeSetStatement : ZSCodeStatement

@property (strong, nonatomic) NSString *variableName;
@property (strong, nonatomic) NSObject *variableValue; // either NSString, or NSNumber, or ZSCodeCallStatement, or NSDictionary (get)

+(id)statementWithVariableName:(NSString *)name
                         value:(NSObject *)value
                         level:(NSInteger)level;
+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;

-(NSString *)variableValueStringValue;

@end
