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
    [cell.spriteView setThumbnailFromJSON:json];
    
    cell.spriteView.contentMode = UIViewContentModeScaleAspectFit;
    cell.spriteView.longPressBegan = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
        if (_longPressBegan) {
            _longPressBegan(longPressGestureRecognizer);
        }
    };
    cell.spriteView.longPressChanged = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
        if (_longPressChanged) {
            _longPressChanged(longPressGestureRecognizer);
        }
    };
    cell.spriteView.longPressEnded = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
        if (_longPressEnded) {
            _longPressEnded(longPressGestureRecognizer);
        }
    };
    
    return cell;
}

@end
