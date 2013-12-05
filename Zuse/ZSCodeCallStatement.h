
#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeCallStatement : ZSCodeStatement

@property (strong, nonatomic) NSString *methodName;
@property (strong, nonatomic) NSMutableArray *args;



- (id)initWithMethodName:(NSString *)name
                    args:(NSMutableArray *)args
             parentSuite:(ZSCodeSuite *)suite;
- (id)initWithJSON:(NSDictionary *)json
       parentSuite:(ZSCodeSuite *)suite;

@end



