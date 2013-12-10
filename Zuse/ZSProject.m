#import "ZSProject.h"

@interface ZSProject ()

@property (nonatomic, strong) NSMutableDictionary *projectJSON;

@end

@implementation ZSProject

+ (ZSProject *)projectWithFile:(NSString *)name {
    return [[ZSProject alloc] initWithFile:name];
}

- (id)init {
    self = [super init];
    if (self) {
        _projectJSON = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithFile:(NSString *)name {
    self = [super init];
    if (self) {
        NSData *jsonData = nil;
        // NSString *path = [self completePathForFile:name];
        // NSLog(@"%@", path);
        // if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //     jsonData = [NSData dataWithContentsOfFile:path];
        // } else {
        // Look for the project in the bundle.
        NSString *modifiedName = [name componentsSeparatedByString:@"."][0];
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:modifiedName ofType:@"json"];
        jsonData = [NSData dataWithContentsOfFile:jsonPath];
        // }
        
        _projectJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
    return self;
}

- (NSMutableDictionary *)assembledJSON {
    return _projectJSON;
}

- (void)writeToFile:(NSString *)name {

}

@end
