#import <Foundation/Foundation.h>

@interface TCSprite : NSObject

@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *imageData;
@property (assign, nonatomic) CGRect frame;
@property (assign, nonatomic) NSMutableArray *traits;
@property(strong, nonatomic) NSMutableArray *code;
@property(strong, nonatomic) TCSprite *identifier;

@end
