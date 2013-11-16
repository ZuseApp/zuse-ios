#import "ZSCodeStatement.h"

@implementation ZSCodeStatement
-(id)init
{
    if (self = [super init])
    {
        self.codeLines = [[NSMutableArray alloc]init];
        self.level = 0;
    }
    return self;
}
@end
