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
    else if ([operator isEqualToString:@"square_root"])operator = @"√";
    else if ([operator isEqualToString:@"random_number"])operator = @"rand";
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
    NSString* parameters = @"parameters: ";
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
    // Function call
    if ([self isFunctionCall: json])
    {
        NSString* functionName = ((NSDictionary*)json)[@"call"][@"method"];
        functionName = [self convertToFansySymbolFromJsonOperator:functionName];
        NSArray* parameters = ((NSDictionary*)json)[@"call"][@"parameters"];
        NSMutableString* parametersString = [[NSMutableString alloc]init];
        
        // form parameters list
        for(NSInteger i = 0; i < parameters.count; i++)
        {
            NSString* parameter = [self recursiveExpressionStringFromJson: parameters[i]];
            
            // delete parenthesys in parameter
            if ([parameter characterAtIndex:0] == '(')
            {
                parameter = [parameter substringWithRange:NSMakeRange(1, parameter.length - 2)];
            }
            [parametersString appendString: parameter];
            
            // append comma
            if (i < parameters.count - 1)
            {
                [parametersString appendString: @", "];
            }
        }
        return [NSString stringWithFormat: @"%@(%@)", functionName, parametersString];
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
            [[ZSZuseDSL everyJSON] deepMutableCopy],
            [[ZSZuseDSL afterJSON] deepMutableCopy],
            [[ZSZuseDSL inJSON] deepMutableCopy],
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
    
    return [methodManifest deepCopy];
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
    
    return [methods deepCopy];
}

+ (NSArray *)emptyFunctions
{
    // get only functions (methods with not none return type) from manifest file
    NSMutableArray* functions = [[NSMutableArray alloc]init];
    for (NSMutableDictionary* method in [self methodManfiest])
    {
        if (![method[@"return_type"] isEqualToString:@"none"])
        {
            NSMutableDictionary* function = [[NSMutableDictionary alloc]init];
            function[@"call"] = [[NSMutableDictionary alloc]init];
            function[@"call"][@"method"] = method[@"name"];
            
            // parameters
            NSMutableArray* parameters = [[NSMutableArray alloc]init];
            for (NSDictionary* parameter in method[@"parameters"])
            {
                [parameters addObject: parameter[@"name"]];
            }
            function[@"call"][@"parameters"] = parameters;
            [functions addObject: function];
        }
    }
    return functions;
}

+ (NSArray*) emptyEvents
{
    NSMutableArray* events = [[NSMutableArray alloc]init];
    NSMutableDictionary* event;
    
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
