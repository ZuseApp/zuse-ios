#import <Foundation/Foundation.h>
#import "ZSCodeSuite.h"

@interface ZSCodeStatement : NSObject

@property (weak, nonatomic) ZSCodeSuite *parentSuite;

- (NSDictionary *) JSONObject;
- (NSArray *) availableVarNames;
@end
