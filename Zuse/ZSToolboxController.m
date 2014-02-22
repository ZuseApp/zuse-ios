#import "ZSToolboxController.h"
#import "ZSSpriteLibrary.h"
#import "ZSSpriteView.h"
#import "ZSToolboxCell.h"
#import "DZNPhotoPickerController.h"

@interface ZSToolboxController ()

@property (strong, nonatomic) NSArray *sprites;

@end

@implementation ZSToolboxController

-(id)init {
    self = [super init];
    if (self)
    {
        _sprites = [ZSSpriteLibrary sharedLibrary].categories;
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray*)_sprites[collectionView.tag][@"sprites"]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZSToolboxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    
    NSMutableDictionary *json = [_sprites[collectionView.tag][@"sprites"][indexPath.row] copy];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(84, 70);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

@end
