#import "ZSGeneratorView.h"
#import "ZSSpriteLibrary.h"
#import "ZSToolboxCell.h"
#import "ZSAddItemCell.h"

@interface ZSGeneratorView ()

@property (strong, nonatomic) NSMutableArray *generators;
@property (nonatomic, strong) UIMenuController *editMenu;
@property (nonatomic, strong) ZSSpriteView *selectedSprite;

@end

@implementation ZSGeneratorView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.generators = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
        self.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
        [self registerClass:ZSToolboxCell.class forCellWithReuseIdentifier:@"cellID"];
        [self registerClass:ZSAddItemCell.class forCellWithReuseIdentifier:@"addItemID"];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.generators.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        ZSAddItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addItemID" forIndexPath:indexPath];
        cell.singleTapped = ^{
            if (self.addGeneratorRequested) {
                self.addGeneratorRequested();
            }
        };
        return cell;
    }
    else {
        ZSToolboxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
        
        NSMutableDictionary *json = [self.generators[row - 1] mutableCopy];
        [cell.spriteView setThumbnailFromJSON:json];
        cell.spriteView.contentMode = UIViewContentModeScaleAspectFit;
        
        WeakSelf
        __weak ZSToolboxCell *weakCell = cell;
        cell.spriteView.singleTapped = ^ {
            if (_singleTapped) {
                _singleTapped(weakCell.spriteView);
            }
        };
        cell.spriteView.longPressBegan = ^(UILongPressGestureRecognizer *longPressGestureRecognizer) {
            [weakSelf becomeFirstResponder];
            _editMenu = [UIMenuController sharedMenuController];
            [_editMenu setTargetRect:weakCell.frame inView:self];
            [_editMenu setMenuVisible:YES animated:YES];
            weakSelf.selectedSprite = weakCell.spriteView;
        };
        [cell.spriteName setText:json[@"name"]];
        cell.spriteName.textColor = [UIColor blackColor];
        
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(73, 57);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

#pragma mark Generator Manipulation

- (void)addGeneratorFromJSON:(NSMutableDictionary*)generatorJSON {
    [self.generators insertObject:generatorJSON atIndex:0];
}

- (void)setupGesturesForGeneratorView:(ZSSpriteView *)view withProperties:(NSMutableDictionary *)properties {
    
}

- (void)setupEditOptionsForGeneratorView:(ZSSpriteView *)view {
    
}

#pragma mark Edit Menu

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(delete:)) {
        return YES;
    }
    return NO;
}

- (void)delete:(id)sender {
    ZSSpriteView *spriteView = self.selectedSprite;
    [self.generators removeObject:spriteView.spriteJSON];
    if (_generatorRemoved) {
        _generatorRemoved(spriteView);
    }
}

@end