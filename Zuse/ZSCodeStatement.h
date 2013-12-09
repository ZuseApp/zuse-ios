#import <Foundation/Foundation.h>
//#import "ZSCodeSuite.h"

@class ZSCodeSuite;

@interface ZSCodeStatement : NSObject

@property (weak, nonatomic) ZSCodeSuite *parentSuite;

+(id)emptyWithParentSuite:(ZSCodeSuite *)suite;

- (id)initWithParentSuite: (ZSCodeSuite *)s;
- (id)initWithJSON:(NSDictionary *)json
       parentSuite:(ZSCodeSuite *)suite;
- (NSDictionary *) JSONObject;
- (NSArray *) availableVarNames;

@end
