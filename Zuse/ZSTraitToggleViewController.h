#import <UIKit/UIKit.h>
#import "ZSTutorial.h"

@interface ZSTraitToggleViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *enabledSpriteTraits;
@property (strong, nonatomic) NSMutableDictionary *projectTraits;
@property (strong, nonatomic) NSDictionary *globalTraits;
@property (copy, nonatomic) NSDictionary *spriteProperties;

- (void)addTapped:(id)sender;

@end