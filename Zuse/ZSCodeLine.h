#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"


typedef NS_ENUM(NSInteger, ZSCodeStatementType)
{
    ZSCodeStatementTypeSet = 0,
    ZSCodeStatementTypeIf,
    ZSCodeStatementTypeOnEvent,
    ZSCodeStatementTypeCall,
    
    ZSCodeStatementTypeNum,  // total number of statements (above) excluding New (below) and Object
    ZSCodeStatementTypeNew,
    ZSCodeStatementTypeObject
};

@interface ZSCodeLine : NSObject

@property (nonatomic) ZSCodeStatementType type;
@property (strong, nonatomic) ZSCodeStatement *statement;

+(id)lineWithType: (ZSCodeStatementType)type
        statement: (ZSCodeStatement *)statement;


@end
