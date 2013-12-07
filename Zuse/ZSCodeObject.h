#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"
#import "ZSCodeSuite.h"

@interface ZSCodeObject : ZSCodeStatement

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) ZSCodeSuite *code;

- (id) initWithJSON: (NSDictionary *) json;
- (NSDictionary *) JSONObject;
- (NSArray *) availableVarNames;

@end
