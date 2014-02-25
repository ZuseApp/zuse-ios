//
//  ZSTraitEditorViewController.h
//  Zuse
//
//  Created by Parker Wightman on 12/9/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSTutorial.h"

@interface ZSTraitEditorViewController : UIViewController <ZSTutorialStage>

@property (strong, nonatomic) NSMutableDictionary *traits;

@end
