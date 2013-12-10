#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, ZSExpressionType) {
    ZSExpressionTypeNumeric = 1 << 0,
    ZSExpressionTypeBoolean = 1 << 1,
    ZSExpressionTypeString  = 1 << 2,
    ZSExpressionTypeAny     = 0x7
};

typedef NS_OPTIONS(NSInteger, ZSExpressionValue) {
    ZSExpressionValueLiteral     = 1 << 0,
    ZSExpressionValueMethod      = 1 << 1,
    ZSExpressionValueProperty    = 1 << 2,
    ZSExpressionValueNewProperty = 1 << 3,
    ZSExpressionValueAny         = 0xf
};

@interface ZSCodeEditorPopoverExpressionOptionsDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *availableVarNames;
- (id) initWithAvailableVarNames:(NSArray *)n;

@end
