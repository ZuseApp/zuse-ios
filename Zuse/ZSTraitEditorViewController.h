#import <UIKit/UIKit.h>
#import "ZSTutorial.h"

@interface ZSTraitEditorViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *projectTraits;
@property (strong, nonatomic) NSDictionary *globalTraits;

- (void)addTapped:(id)sender;

@end
