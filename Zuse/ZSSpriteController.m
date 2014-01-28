//
//  ZSSpriteController.m
//  Zuse
//
//  Created by Michael Hogenson on 10/12/13.
//  Copyright (c) 2013 Michael Hogenson. All rights reserved.
//

#import "ZSSpriteController.h"
#import "ZSSpriteLibrary.h"
#import "ZSSpriteView.h"
#import "ZSSpriteTableViewCell.h"

@interface ZSSpriteController ()

@property (strong, nonatomic) NSArray *spriteLibrary;

@end

@implementation ZSSpriteController

-(id)init {
    self = [super init];
    if (self)
    {
        _spriteLibrary = [ZSSpriteLibrary spriteLibrary];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_spriteLibrary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZSSpriteTableViewCell *cell = (ZSSpriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"sprite"];
    
    NSMutableDictionary *json = [_spriteLibrary[indexPath.row] copy];
    cell.spriteView.spriteJSON = json;
    
    NSString *type = json[@"type"];
    if ([type isEqualToString:@"image"]) {
        NSDictionary *image = json[@"image"];
        NSString *imagePath = image[@"path"];
        [cell.spriteView setContentFromImage:[UIImage imageNamed:imagePath]];
    }
    else if ([type isEqualToString:@"text"]) {
        [cell.spriteView setContentFromImage:[UIImage imageNamed:@"text_icon.png"]];
    }
    
    cell.spriteView.contentMode = UIViewContentModeScaleAspectFit;
    cell.spriteView.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        if (_panBegan) {
            _panBegan(panGestureRecognizer, json);
        }
    };
    cell.spriteView.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        if (_panMoved) {
            _panMoved(panGestureRecognizer, json);
        }
    };
    cell.spriteView.panEnded = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        if (_panEnded) {
            _panEnded(panGestureRecognizer, json);
        }
    };
    
    return cell;
}

@end
