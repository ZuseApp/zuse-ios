#import <Foundation/Foundation.h>

@interface ZSSprite : NSObject

@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *imageData;
@property (assign, nonatomic) CGRect frame;
@property (assign, nonatomic) NSMutableArray *traits;
@property (strong, nonatomic) NSMutableArray *code;
@property (strong, nonatomic) ZSSprite *identifier;
@property (strong, nonatomic) NSString *physicsBody;

-(id) initWithJSON:(NSDictionary *)json;
-(NSString *) spriteJSON;

@end
