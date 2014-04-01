#import "ZS_JsonUtilities.h"
#import "ZSZuseDSL.h"
#import "BlocksKit.h"

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
    if ([self isNumber: json])
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
    else if ([self isString: json])
    {
        return (NSString*)json;
    }
    // Variable Name
    else if ([self isVariableName: json])
    {
        return ((NSDictionary*)json)[@"get"];
    }
    // Operator
    else if ([self isOperator: json])
    {
        NSString* key = ((NSDictionary*)json).allKeys[0];
        
        NSString* leftExpression = [self recursiveExpressionStringFromJson: ((NSDictionary*)json)[key][0]];
        NSString* operator = [self convertToFansySymbolFromJsonOperator: key];
        NSString* rightExpression = [self recursiveExpressionStringFromJson: ((NSDictionary*)json)[key][1]];
        
        return [NSString stringWithFormat:@"(%@ %@ %@)", leftExpression, operator, rightExpression];
    }
    // Square root function call
    else if ([self isSqrtFunctionCall: json])
    {
        NSObject* jsonExpression = ((NSDictionary*)json)[@"call"][@"parameters"][0];
        NSString* expression = [self recursiveExpressionStringFromJson: jsonExpression];
        return [NSString stringWithFormat:@"√%@", expression];
    }
    // Random number function call
    else if ([self isRandomNumberFunctionCall: json])
    {
        NSObject* jsonParam1 = ((NSDictionary*)json)[@"call"][@"parameters"][0];
        NSString* param1 = [self recursiveExpressionStringFromJson: jsonParam1];
        NSObject* jsonParam2 = ((NSDictionary*)json)[@"call"][@"parameters"][1];
        NSString* param2 = [self recursiveExpressionStringFromJson: jsonParam2];
        
        // delete parenthesys in param1 and param2
        if ([param1 characterAtIndex:0] == '(')
        {
            param1 = [param1 substringWithRange:NSMakeRange(1, param1.length - 2)];
        }
        if ([param2 characterAtIndex:0] == '(')
        {
            param2 = [param2 substringWithRange:NSMakeRange(1, param2.length - 2)];
        }
        // Form the expression
        return [NSString stringWithFormat:@"rand(%@, %@)", param1, param2];
    }
    return nil;
}
+ (BOOL) isOperator:(NSObject*) json
{
    if ([json isKindOfClass:[NSMutableDictionary class]])
    {
        NSString* key = ((NSMutableDictionary*)json).allKeys[0];
        return [key isEqualToString:@"+"]
        || [key isEqualToString:@"-"]
        || [key isEqualToString:@"*"]
        || [key isEqualToString:@"/"]
        || [key isEqualToString:@"%"]
        || [key isEqualToString:@">"]
        || [key isEqualToString:@"<"]
        || [key isEqualToString:@">="]
        || [key isEqualToString:@"<="]
        || [key isEqualToString:@"=="]
        || [key isEqualToString:@"!="]
        || [key isEqualToString:@"and"]
        || [key isEqualToString:@"or"];
    }
    return NO;
}
+ (BOOL) isFunctionCall:(NSObject*) json
{
    if ([json isKindOfClass:[NSMutableDictionary class]])
    {
        return [((NSMutableDictionary*)json).allKeys[0] isEqualToString:@"call"];
    }
    return NO;
}
+ (BOOL) isSqrtFunctionCall:(NSObject*) json
{
    if ([self isFunctionCall:json])
    {
        return [((NSDictionary*)json)[@"call"][@"method"] isEqualToString:@"square root"];
    }
    return NO;
}
+ (BOOL) isRandomNumberFunctionCall:(NSObject*) json
{
    if ([self isFunctionCall:json])
    {
        return [((NSDictionary*)json)[@"call"][@"method"] isEqualToString:@"random_number"];
    }
    return NO;
}
+ (BOOL) isVariableName:(NSObject*) json
{
    if ([json isKindOfClass:[NSMutableDictionary class]])
    {
        return [((NSMutableDictionary*)json).allKeys[0] isEqualToString:@"get"];
    }
    return NO;
}
+ (BOOL) isString:(NSObject*) json
{
    return [json isKindOfClass:[NSString class]];
}
+ (BOOL) isNumber:(NSObject*) json
{
    return [json isKindOfClass:[NSNumber class]];
}
+ (NSArray*) emptyStatements
{
    NSArray *statements = nil;
    
//    if (!statements) {
        statements = @[
            [[ZSZuseDSL onEventJSON] deepMutableCopy],
            [[ZSZuseDSL triggerEventJSON] deepMutableCopy],
            [[ZSZuseDSL ifJSON] deepMutableCopy],
            [[ZSZuseDSL setJSON] deepMutableCopy]
        ];
//    }
    
    return statements;
}

+ (NSArray *)methodManfiest {
    static NSArray *methodManifest = nil;
    
    if (!methodManifest) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"method_manifest" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        NSError *error = nil;
        methodManifest = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&error];
        assert(!error);
    }
    
    return methodManifest;
}

// TODO: This could be sped up by creating a dictionary from the array,
// but I don't foresee it being called enough to slow anything down.
//   - Parker
+ (NSDictionary *)manifestForMethodIdentifier:(NSString *)identifier {
    return [[self methodManfiest] match:^BOOL(NSDictionary *manifestItem) {
        return [manifestItem[@"name"] isEqualToString:identifier];
    }];
}

+ (NSArray *)emptyMethods {

    static NSArray *methods = nil;
    
    if (!methods) {
        NSArray *manifestMethods = [self methodManfiest];
        methods = [manifestMethods map:^id(NSDictionary *manifestJSON) {
            return [ZSZuseDSL callFromManifestJSON:manifestJSON];
        }];
    }
    
    return methods;
}

+ (NSArray*) emptyEvents
{
    NSMutableArray* events = [[NSMutableArray alloc]init];
    NSMutableDictionary* event;
    
    // start
    event =  [[NSMutableDictionary alloc]init];
    event[@"name"] = @"start";
    event[@"parameters"] = [NSMutableArray arrayWithArray:@[]];
    [events addObject: event];
    
    // collision
    event =  [[NSMutableDictionary alloc]init];
    event[@"name"] = @"collision";
    event[@"parameters"] = [NSMutableArray arrayWithArray:@[@"other_group"]];
    [events addObject: event];
    
    // touch_began
    event =  [[NSMutableDictionary alloc]init];
    event[@"name"] = @"touch_began";
    event[@"parameters"] = [NSMutableArray arrayWithArray:@[@"touch_x", @"touch_y"]];
    [events addObject: event];
    
    // touch_moved
    event =  [[NSMutableDictionary alloc]init];
    event[@"name"] = @"touch_moved";
    event[@"parameters"] = [NSMutableArray arrayWithArray:@[@"touch_x", @"touch_y"]];
    [events addObject: event];
    
    // touch_ended
    event =  [[NSMutableDictionary alloc]init];
    event[@"name"] = @"touch_ended";
    event[@"parameters"] = [NSMutableArray arrayWithArray:@[@"touch_x", @"touch_y"]];
    [events addObject: event];
    
    return events;
}
@end
