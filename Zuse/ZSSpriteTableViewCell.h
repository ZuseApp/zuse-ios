//
//  ZSSpriteTableViewCell.h
//  Zuse
//
//  Created by Michael Hogenson on 12/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSSpriteView.h"

@interface ZSSpriteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ZSSpriteView *spriteView;

@end
