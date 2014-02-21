#import <UIKit/UIKit.h>
#import "ZSSpriteView.h"

@interface ZSToolboxCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet ZSSpriteView *spriteView;
@property (weak, nonatomic) IBOutlet UILabel *spriteName;

@end
