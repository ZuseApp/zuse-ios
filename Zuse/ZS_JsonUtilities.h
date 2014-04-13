#import <Foundation/Foundation.h>

@interface ZS_JsonUtilities : NSObject
+ (NSString*) convertToFansySymbolFromJsonOperator: (NSString*) operator;
+ (NSMutableDictionary*) jsonFromFileWithName: (NSString*) filename;
+ (NSString*) propertiesStringFromJson: (NSDictionary*) json;
+ (NSString*) parametersStringFromJson: (NSArray*) json;
+ (NSString*) expressionStringFromJson: (NSObject*) json;

+ (BOOL) isOperator:(NSObject*) json;
+ (BOOL) isFunctionCall:(NSObject*) json;
+ (BOOL) isVariableName:(NSObject*) json;
+ (BOOL) isString:(NSObject*) json;
+ (BOOL) isNumber:(NSObject*) json;

+ (NSArray*) emptyStatements;
+ (NSArray*) emptyEvents;
+ (NSArray*) emptyMethods;
+ (NSArray *)emptyFunctions;
+ (NSDictionary *)manifestForMethodIdentifier:(NSString *)identifier;
@end
