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
    cell.spriteView.panBegan = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        if (_panBegan) {
            _panBegan(panGestureRecognizer);
        }
    };
    cell.spriteView.panMoved = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        if (_panMoved) {
            _panMoved(panGestureRecognizer);
        }
    };
    cell.spriteView.panEnded = ^(UIPanGestureRecognizer *panGestureRecognizer) {
        if (_panEnded) {
            _panEnded(panGestureRecognizer);
        }
    };
    
    return cell;
}

@end
