#import "ZSProject.h"
#import "ZSSpriteTraits.h"

@interface ZSProject ()

@property (nonatomic, strong) NSMutableDictionary *projectJSON;
@property (nonatomic, strong) NSString *documentsPath;
@property (nonatomic, strong) NSString *fileName;

@end

@implementation ZSProject

+ (ZSProject *)projectWithFile:(NSString *)name {
    return [[ZSProject alloc] initWithFile:name];
}

+ (ZSProject *)projectWithTemplate:(NSString *)name {
    return [[ZSProject alloc] initWithTemplate:name];
}

- (id)init {
    self = [super init];
    if (self) {
        // Set up documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [paths objectAtIndex:0];
        
        // Create an empty project.
        _title = @"Untitled";
        _version = @"1.0.0";
        _fileName = [NSString stringWithFormat:@"%@.json",[[NSUUID UUID] UUIDString]];
        _projectJSON = [NSMutableDictionary dictionary];
        [_projectJSON setObject:_title forKey:@"title"];
        [_projectJSON setObject:[NSMutableDictionary dictionary] forKey:@"traits"];
        [_projectJSON setObject:[NSMutableArray array] forKey:@"objects"];
    }
    return self;
}

- (id)initWithFile:(NSString *)name {
    self = [super init];
    if (self) {
        _fileName = name;
        
        // Set up documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [paths objectAtIndex:0];
        
        // Load the file.
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", _documentsPath, name];
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
        _projectJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        _title = _projectJSON[@"title"];
        _version = _projectJSON[@"version"];
    }
    return self;
}

- (id)initWithTemplate:(NSString *)name {
    self = [super init];
    if (self) {
        _fileName = name;
        
        // Set up documents directory even though the bundle direcoty is being read.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [paths objectAtIndex:0];
        
        // Load the project from a template.
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", bundleRoot, name];
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
        _projectJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        _title = _projectJSON[@"title"];
        _version = _projectJSON[@"version"];
    }
    return self;
}

- (NSMutableDictionary *)rawJSON {
    return _projectJSON;
}

- (NSMutableDictionary *)assembledJSON {
    if (_title) {
        _projectJSON[@"title"] = _title;
    }
    if (_version) {
        _projectJSON[@"version"] = _version;
    }
    _projectJSON[@"traits"] = [ZSSpriteTraits defaultTraits];
    return _projectJSON;
}

- (void)write {
    NSDictionary *assembledJSON = [[self assembledJSON] deepCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:assembledJSON options:NSJSONWritingPrettyPrinted error:&error];
        if (!jsonData) {
            NSLog(@"Error serializing: %@", error);
        } else {
            [jsonData writeToFile:[_documentsPath stringByAppendingPathComponent:_fileName] atomically:YES];
        }
    });
}

@end
