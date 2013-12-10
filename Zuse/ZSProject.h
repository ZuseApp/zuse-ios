#import <Foundation/Foundation.h>

@interface ZSProject : NSObject

+ (ZSProject *)projectWithFile:(NSString *)name;

- (id)init;
- (id)initWithFile:(NSString *)name;
- (NSMutableDictionary *)assembledJSON;
- (void)writeToFile:(NSString *)name;

@end
