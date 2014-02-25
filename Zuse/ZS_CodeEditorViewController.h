#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZS_StatementType)
{
    ZS_StatementTypeOnEvent,
    ZS_StatementTypeIf,
    ZS_StatementTypeSet,
    ZS_StatementTypeCall,
    ZS_StatementTypeTriggerEvent
};

@interface ZS_CodeEditorViewController : UIViewController
//@property (strong, nonatomic) NSMutableDictionary* spriteObject;
@property (strong, nonatomic) NSMutableDictionary* json;
@end
