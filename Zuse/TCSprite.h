#import <Foundation/Foundation.h>

@interface TCSprite : NSObject

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGRect frame;
@property (assign, nonatomic) NSMutableArray *traits;
@property(strong, nonatomic) NSMutableArray *code;
@property(strong, nonatomic) TCSprite *identifier;

-(id)initWithImage:(UIImage *) image;

@end
