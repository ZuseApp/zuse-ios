//
//  ZSCodeCallStatement.h
//  Code Editor 2
//
//  Created by Vladimir on 10/22/13.
//  Copyright (c) 2013 turing-complete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSCodeStatement.h"

@interface ZSCodeCallStatement : ZSCodeStatement

@property (strong, nonatomic) NSString *methodName;
@property (strong, nonatomic) NSMutableArray *args;

+(id)statementWithMethodName:(NSString *)name
                        args:(NSMutableArray *)args
                       level:(NSInteger)level;
+(id)statementWithJSON:(NSDictionary *)json
                 level:(NSInteger)level;

@end



