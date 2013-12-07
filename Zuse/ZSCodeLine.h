#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ZSCodeStatementType)
{
    ZSCodeStatementTypeSet = 0,
    ZSCodeStatementTypeIf,
    ZSCodeStatementTypeOnEvent,
    ZSCodeStatementTypeCall,
    
    ZSCodeStatementTypeNum,  // total number of statements (above) excluding New (below)
    ZSCodeStatementTypeNew
};

@class ZSCodeStatement;

@interface ZSCodeLine : NSObject

@property (nonatomic) ZSCodeStatementType type;
@property (nonatomic) NSInteger indentation;
@property (strong, nonatomic) ZSCodeStatement *statement;

+(id)lineWithType:(ZSCodeStatementType)type
      indentation:(NSInteger)indentation
        statement:(ZSCodeStatement *)statement;
@end
