#import <Foundation/Foundation.h>

@interface ZSCodeEditorPopoverVarNameOptionsDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *availableVarNames;
- (id) initWithAvailableVarNames:(NSArray *)n;

@end
