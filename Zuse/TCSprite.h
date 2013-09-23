#import <Foundation/Foundation.h>

@interface TCSprite : NSObject

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGPoint origin;

-(id)initWithImage:(UIImage *) image;

@end
