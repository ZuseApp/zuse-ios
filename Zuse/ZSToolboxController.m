//
//  ZSToolboxController.m
//  Zuse
//
//  Created by Michael Hogenson on 2/20/14.
//  Copyright (c) 2014 Michael Hogenson. All rights reserved.
//

#import "ZSToolboxController.h"
#import "ZSSpriteLibrary.h"
#import "ZSSpriteView.h"
#import "ZSToolboxCell.h"

@interface ZSToolboxController ()

@property (strong, nonatomic) NSArray *spriteLibrary;

@end

@implementation ZSToolboxController

-(id)init {
    self = [super init];
    if (self)
    {
        _spriteLibrary = [ZSSpriteLibrary spriteLibrary];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [_spriteLibrary count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZSToolboxCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    
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
    [cell.spriteName setText:json[@"name"]];
    
    return cell;
}

@end
