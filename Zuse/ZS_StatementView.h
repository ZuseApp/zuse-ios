#import <UIKit/UIKit.h>

@class ZSCodePropertyScope;
@class ZS_StatementView;

@protocol ZS_StatementViewDelegate <NSObject>
-(void) statementViewLongPressed: (ZS_StatementView*) view;
@end

@interface ZS_StatementView : UIView

@property (weak, nonatomic) id<ZS_StatementViewDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary* json;
@property (strong, nonatomic) NSMutableArray* jsonCode;
@property (nonatomic, getter = isTopLevelStatement) BOOL topLevelStatement;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;

@property (strong, nonatomic) ZSCodePropertyScope *propertyScope;
@property (strong, nonatomic) NSSet *(^propertiesInScope)();

- (instancetype) initWithJson: (NSMutableDictionary*) json;
- (void) addNameLabelWithText: (NSString*) text;
- (void) addParametersLabelWithText: (NSString*) text;
- (void) addArgumentLabelWithText: (NSString*) text touchBlock: (void(^)(UILabel*)) touchBlock;
- (void) addSubStatementView: (ZS_StatementView*) subStatementView;
- (void) addNewStatementLabelWithTouchBlock: (void(^)(UILabel*)) touchBlock;
- (void) layoutStatementSubviews;
@end
