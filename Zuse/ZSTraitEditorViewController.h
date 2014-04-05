//
//  ZSTraitEditorViewController.h
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSTutorial.h"

@interface ZSTraitEditorViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *enabledSpriteTraits;
@property (strong, nonatomic) NSMutableDictionary *projectTraits;
@property (strong, nonatomic) NSDictionary *globalTraits;

- (void)addTapped:(id)sender;

@end
