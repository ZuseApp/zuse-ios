#import "TCSprite.h"

@implementation TCSprite

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

@end
    