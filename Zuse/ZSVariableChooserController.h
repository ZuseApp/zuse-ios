//
//  ZSVariableChooser.h
//  Zuse
//
//  Created by Vladimir on 3/1/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSVariableChooserController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (copy, nonatomic) void(^singleTapped)(NSString *variable);
@property (nonatomic, strong) NSSet *variables;

@end
