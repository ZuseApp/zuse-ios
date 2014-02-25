#import <UIKit/UIKit.h>

@interface ZS_StatementView : UIView

@property (strong, nonatomic) NSMutableDictionary* json;
@property (strong, nonatomic) NSMutableArray* jsonCode;
@property (nonatomic, getter = isTopLevelStatement) BOOL topLevelStatement;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;

- (instancetype) initWithJson: (NSMutableDictionary*) json;

- (void) addNameLabelWithText: (NSString*) text;
- (void) addParametersLabelWithText: (NSString*) text;
- (void) addArgumentLabelWithText: (NSString*) text touchBlock: (void(^)(UILabel*)) touchBlock;
- (void) addSubStatementView: (ZS_StatementView*) subStatementView;
- (void) addNewStatementLabelWithTouchBlock: (void(^)(UILabel*)) touchBlock;
@end
