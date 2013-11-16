//
//  ZSCodeLine.h
//  Code Editor 2
//
//  Created by Vladimir on 10/24/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const IF_STATEMENT_TYPE;
extern NSString *const ZSCodeLineStatementIf;
extern NSString *const ZSCodeLineStatementCall;
extern NSString *const CALL_STATEMENT_TYPE;
extern NSString *const SET_STATEMENT_TYPE;
extern NSString *const NEW_STATEMENT_TYPE;
extern NSString *const DEFAULT_STATEMENT_TYPE;

@interface ZSCodeLine : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *type;
@property (nonatomic) NSInteger indentation;

+(id)lineWithText:(NSString *)text
             type:(NSString *)type
      indentation:(NSInteger)idnent;
@end
