#import "ZS_JsonUtilities.h"

@implementation ZS_JsonUtilities

+ (NSMutableDictionary*) jsonFromFileWithName: (NSString*) filename
{
    NSString *fullPath = [[NSBundle bundleForClass:[self class]] pathForResource: filename
                                                                          ofType: @"json"];
    NSMutableDictionary* json =
    [NSJSONSerialization JSONObjectWithData: [NSData dataWithContentsOfFile: fullPath]
                                    options: NSJSONReadingMutableContainers
                                      error: nil];
    
    
    return json;
}
+ (NSString*) convertToFansySymbolFromJsonOperator: (NSString*) operator
{
    operator = [operator stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if      ([operator isEqualToString:@"+"])   operator = @" + ";
    else if ([operator isEqualToString:@"-"])   operator = @" − ";
    else if ([operator isEqualToString:@"*"])   operator = @" × ";
    else if ([operator isEqualToString:@"/"])   operator = @" ÷ ";
    else if ([operator isEqualToString:@"%"])   operator = @" % ";
    else if ([operator isEqualToString:@"sqrt"])operator = @" √ ";
    else if ([operator isEqualToString:@">"])   operator = @" > ";
    else if ([operator isEqualToString:@"<"])   operator = @" < ";
    else if ([operator isEqualToString:@">="])  operator = @" ≥ ";
    else if ([operator isEqualToString:@"<="])  operator = @" ≤ ";
    else if ([operator isEqualToString:@"=="])  operator = @" = ";
    else if ([operator isEqualToString:@"!="])  operator = @" ≠ ";
    else if ([operator isEqualToString:@"and"]) operator = @" and ";
    else if ([operator isEqualToString:@"or"])  operator = @" or ";
    return operator;
}
+ (NSString*) propertiesStringFromJson: (NSDictionary*) json
{
    NSString* properties = @"OBJECT PROPERTIES:\n";
    for (NSString* key in json.allKeys)
    {
        NSString* value = json[key];
        
        // if boolean number
        if ((value == (void*)kCFBooleanFalse || value == (void*)kCFBooleanTrue))
        {
            value = ((NSNumber*)json[key]).intValue ? @"true" : @"false";
        }
        properties = [NSString stringWithFormat:@"%@%@=%@, ", properties, key, value];
    }
    properties = [properties substringToIndex:properties.length - 2];
    return properties;
}
+ (NSString*) parametersStringFromJson: (NSArray*) json
{
    NSString* parameters = @"PARAMETERS: ";
    for (NSString* parameter in json)
    {
        parameters = [NSString stringWithFormat:@"%@%@, ", parameters, parameter];
    }
    parameters = [parameters substringToIndex: parameters.length - 2];
    return parameters;
}
+ (NSString*) expressionStringFromJson: (NSObject*) json
{
    // form expression from json
    NSString* expression = [self recursiveExpressionStringFromJson:json];
    
    // remove parenthesys if needed
    if ([expression characterAtIndex:0] == '(')
    {
        expression  = [expression substringWithRange:NSMakeRange(1, expression.length - 2)];
    }
    return expression;
}
// Helper for expressionStringFromJson:
+ (NSString*) recursiveExpressionStringFromJson: (NSObject*) json
{
    // Number
    if ([json isKindOfClass:[NSNumber class]])
    {
        NSNumber* number = (NSNumber*)json;
        
        // if boolean number
        if ((number == (void*)kCFBooleanFalse || number == (void*)kCFBooleanTrue))
        {
            return number.intValue ? @"true" : @"false";
        }
        else
        {
            return number.stringValue;
        }
    }
    // String
    else if ([json isKindOfClass:[NSString class]])
    {
        return (NSString*)json;
    }
    // Variable or Math Expression
    else if ([json isKindOfClass:[NSDictionary class]])
    {
        NSString* key = ((NSDictionary*)json).allKeys[0];
        
        // Variable
        if ([key isEqualToString:@"get"])
        {
            return ((NSDictionary*)json)[@"get"];
        }
        
        // Math Expression
        else
        {
            NSString* leftNode = [self expressionStringFromJson: ((NSDictionary*)json)[key][0]];
            NSString* operator = [self convertToFansySymbolFromJsonOperator: key];
            NSString* rightNode = [self expressionStringFromJson: ((NSDictionary*)json)[key][1]];
            
            return [NSString stringWithFormat:@"(%@ %@ %@)", leftNode, operator, rightNode];
        }
    }
    return nil;
}

@end
