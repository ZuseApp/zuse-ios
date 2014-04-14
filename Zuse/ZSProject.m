#import "ZSProject.h"
#import "ZSProjectJSONKeys.h"
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
        // Grab the size of the screen to create the project size correctly.
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        // Create an empty project.
        _title = @"Untitled";
        _version = @"1.0.0";
        _canvasSize = @[@(screenSize.width), @(screenSize.height - 44)];
        _identifier = [[NSUUID UUID] UUIDString];
                
        _projectJSON = [NSMutableDictionary dictionary];

        _projectJSON[@"title"]              = self.title;
        _projectJSON[@"id"]                 = self.identifier;
        _projectJSON[@"canvas_size"]        = self.canvasSize;
        _projectJSON[@"traits"]             = [NSMutableDictionary dictionary];
        _projectJSON[@"objects"]            = [NSMutableArray array];
        _projectJSON[@"generators"]         = [NSMutableArray array];
        _projectJSON[@"commit_number"]      = @(0);
        _projectJSON[ZSProjectJSONKeyGroup] = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithFile:(NSString *)filePath {
    self = [super init];
    if (self) {
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        _projectJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
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
    _identifier   = _projectJSON[@"id"];
    _title        = _projectJSON[@"title"];
    _version      = _projectJSON[@"version"];
    _canvasSize   = _projectJSON[@"canvas_size"];
    _commitNumber = [_projectJSON[@"commit_number"] integerValue];
}

- (NSMutableDictionary *)rawJSON {
    return _projectJSON;
}

- (NSMutableDictionary *)assembledJSON {
    if (self.title) {
        self.projectJSON[@"title"] = self.title;
    }
    if (self.version) {
        self.projectJSON[@"version"] = self.version;
    }
    
    if (self.canvasSize) {
        self.projectJSON[@"canvas_size"] = self.canvasSize;
    }
    
    if (self.identifier) {
        self.projectJSON[@"id"] = self.identifier;
    }

    self.projectJSON[@"commit_number"] = @(self.commitNumber);

    // Find all of the traits being referenced in the project by looking at all of the sprites.
    NSMutableArray *traitsReferencedInProject = [NSMutableArray array];
    for (NSMutableDictionary *sprites in self.projectJSON[@"objects"]) {
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
    NSMutableDictionary *previouslySavedTraits = self.projectJSON[@"traits"];
    for (NSString *trait in traitsReferencedInProject) {
        if (!previouslySavedTraits[trait]) {
            if (defaultTraits[trait]) {
                previouslySavedTraits[trait] = defaultTraits[trait];
            }
        }
    }
    return self.projectJSON;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<ZSProject title=%@ id=%@>", self.title, self.identifier];
}

@end
