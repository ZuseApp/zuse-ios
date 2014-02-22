#import "ZSProject.h"
#import "ZSSpriteTraits.h"

@interface ZSProject ()

@property (nonatomic, strong) NSMutableDictionary *projectJSON;
@property (nonatomic, strong) NSString *documentsPath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSArray *canvasSize;

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
        _canvasSize = @[@(320), @(524)];
        _fileName = [NSString stringWithFormat:@"%@.json",[[NSUUID UUID] UUIDString]];
        _projectJSON = [NSMutableDictionary dictionary];
        [_projectJSON setObject:_title forKey:@"title"];
        [_projectJSON setObject:[NSMutableDictionary dictionary] forKey:@"traits"];
        [_projectJSON setObject:[NSMutableArray array] forKey:@"objects"];
        [_projectJSON setObject:[NSMutableDictionary dictionary] forKey:@"collision_groups"];
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
        _canvasSize = _projectJSON[@"canvasSize"];
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
        
        // If the project json is an array then it can't be a valid project file so return
        // a blank project.
        if ([_projectJSON isKindOfClass:[NSArray class]]) {
            return nil;
        }
        
        _title = _projectJSON[@"title"];
        _version = _projectJSON[@"version"];
        _canvasSize = _projectJSON[@"canvasSize"];
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
    
    if (_canvasSize) {
        _projectJSON[@"canvasSize"] = _canvasSize;
    }
    
    // Find all of the traits being referenced in the project by looking at all of the sprites.
    NSMutableArray *traitsReferencedInProject = [NSMutableArray array];
    for (NSMutableDictionary *sprites in _projectJSON[@"objects"]) {
        NSMutableDictionary *traits = sprites[@"traits"];
        if (traits) {
            for (NSString *key in traits) {
                [traitsReferencedInProject addObject:key];
            }
        }
    }
    
    // Go through all of the traits referenced in the project and if they don't exist already
    // add them to the project JSON.
    NSDictionary *defaultTraits = [ZSSpriteTraits defaultTraits];
    NSMutableDictionary *previouslySavedTraits = _projectJSON[@"traits"];
    for (NSString *trait in traitsReferencedInProject) {
        if (!previouslySavedTraits[trait]) {
            if (defaultTraits[trait]) {
                previouslySavedTraits[trait] = defaultTraits[trait];
            }
        }
    }
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
