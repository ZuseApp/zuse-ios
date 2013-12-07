#import <Foundation/Foundation.h>


@class ZSCodeSuite;

@interface ZSCodeStatement : NSObject

@property (weak, nonatomic) ZSCodeSuite *parentSuite;

- (NSDictionary *) JSONObject;
- (NSArray *) availableVarNames;

@end
