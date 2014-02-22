#import <Foundation/Foundation.h>

@interface ZS_JsonUtilities : NSObject
+ (NSString*) convertToFansySymbolFromJsonOperator: (NSString*) operator;
+ (NSMutableDictionary*) jsonFromFileWithName: (NSString*) filename;
+ (NSString*) propertiesStringFromJson: (NSDictionary*) json;
+ (NSString*) parametersStringFromJson: (NSArray*) json;
+ (NSString*) expressionStringFromJson: (NSObject*) json;
@end
