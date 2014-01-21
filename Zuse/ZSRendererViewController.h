//
//  ZSInterpreterViewController.h
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRendererViewController : UIViewController

@property (strong, nonatomic) NSDictionary *projectJSON;

- (void)play;
- (void)resume;
- (void)stop;

@end
