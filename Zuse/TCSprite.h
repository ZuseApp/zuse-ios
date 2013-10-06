#import <Foundation/Foundation.h>

@interface TCSprite : NSObject

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGRect frame;
@property(strong, nonatomic) NSMutableArray *code;

-(id)initWithImage:(UIImage *) image;

@end
