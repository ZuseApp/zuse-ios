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
