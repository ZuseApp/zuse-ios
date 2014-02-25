#import "ZSSpriteLibrary.h"

@implementation ZSSpriteLibrary

+ (id)sharedLibrary {
    static ZSSpriteLibrary *library = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library = [[self alloc] init];
    });
    return library;
}

- (id)init {
    self = [super init];
    if (self) {
        _categories = [self loadLibrary];
    }
    return self;
}

- (NSMutableArray *)loadLibrary {
    // Load sprites from the manifest file.
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [bundleRoot stringByAppendingPathComponent:@"sprite_manifest.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray *manifestJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableArray *categories = [NSMutableArray array];
    for (NSDictionary *manifest_group in manifestJSON) {
        NSMutableDictionary *group = [NSMutableDictionary dictionary];
        group[@"category"] = manifest_group[@"category"];
        
        NSMutableArray *sprites = [NSMutableArray array];
        for (NSMutableDictionary *manifest_sprite in manifest_group[@"sprites"]) {
            NSDictionary *sprite = @{
                                     @"name": manifest_sprite[@"name"],
                                     @"physics_body": manifest_sprite[@"physics_body"],
                                     @"traits": @{},
                                     @"properties": @{
                                             @"width": manifest_sprite[@"preferred_size"][@"width"],
                                             @"height": manifest_sprite[@"preferred_size"][@"height"]
                                             },
                                     @"image": @{
                                             @"path": manifest_sprite[@"path"],
                                             },
                                     @"code": @[],
                                     @"type": @"image"
                                     };
            [sprites addObject:sprite];
        }
        group[@"sprites"] = sprites;
        [categories addObject:group];
    }
    
    NSDictionary *controlGroup = @{
                                   @"category": @"Controls",
                                   @"sprites":@[
                                           @{
                                               @"name": @"Text Box",
                                               @"physics_body": @"rectangle",
                                               @"traits": @{},
                                               @"properties": @{
                                                       @"width": @(200),
                                                       @"height": @(21)
                                                       },
                                               @"code": @[],
                                               @"type": @"text"
                                               }
                                           ]
                                   };
    [categories addObject:controlGroup];
    
    return categories;
}

@end
