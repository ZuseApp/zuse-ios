#import <Foundation/Foundation.h>

@interface ZSProject : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *version;

+ (ZSProject *)projectWithFile:(NSString *)name;
+ (ZSProject *)projectWithTemplate:(NSString *)name;

- (id)init;
- (id)initWithFile:(NSString *)name;
- (NSMutableDictionary *)assembledJSON;
- (void)write;

@end
