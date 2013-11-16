#import <Foundation/Foundation.h>

@interface ZSCodeStatement : NSObject

@property (strong, nonatomic) NSMutableArray *codeLines;
@property (nonatomic) NSInteger level;

-(id)init;

@end
