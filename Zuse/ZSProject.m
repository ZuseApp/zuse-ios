#import "ZSProject.h"
#import "ZSSpriteTraits.h"

@interface ZSProject ()

@property (nonatomic, strong) NSMutableDictionary *projectJSON;
@property (nonatomic, strong) NSString *documentsPath;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSArray *canvasSize;

@end

@implementation ZSProject

+ (ZSProject *)projectWithFile:(NSString *)name {
    return [[ZSProject alloc] initWithFile:name];
}

+ (ZSProject *)projectWithJSON:(NSDictionary *)JSON {
    return [[ZSProject alloc] initWithJSON:JSON];
}

- (id)init {
    self = [super init];
    if (self) {
        // Create an empty project.
        _title = @"Untitled";
        _version = @"1.0.0";
        _canvasSize = @[@(320), @(524)];
        _identifier = [[NSUUID UUID] UUIDString];
        
        _projectJSON = [NSMutableDictionary dictionary];
        [_projectJSON setObject:_title forKey:@"title"];
        [_projectJSON setObject:_identifier forKey:@"id"];
        [_projectJSON setObject:_canvasSize forKey:@"canvas_size"];
        [_projectJSON setObject:[NSMutableDictionary dictionary] forKey:@"traits"];
        [_projectJSON setObject:[NSMutableArray array] forKey:@"objects"];
        [_projectJSON setObject:[NSMutableDictionary dictionary] forKey:@"groups"];
    }
    return self;
}

- (id)initWithFile:(NSString *)filePath {
    self = [super init];
    if (self) {
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
        _projectJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        [self sharedInit];
    }
    return self;
}

- (id) initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    
    if (self) {
        _projectJSON = [JSON deepMutableCopy];
        [self sharedInit];
    }
    
    return self;
}

- (void)sharedInit {
    if (!_projectJSON[@"id"]) {
        _projectJSON[@"id"] = [[NSUUID UUID] UUIDString];
    }
    _identifier = _projectJSON[@"id"];
    _title      = _projectJSON[@"title"];
    _version    = _projectJSON[@"version"];
    _canvasSize = _projectJSON[@"canvasSize"];
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
        _projectJSON[@"canvas_size"] = _canvasSize;
    }
    
    if (_identifier) {
        _projectJSON[@"id"] = _identifier;
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

@end
