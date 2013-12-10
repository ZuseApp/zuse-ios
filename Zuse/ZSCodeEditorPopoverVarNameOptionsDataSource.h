#import <Foundation/Foundation.h>

@interface ZSCodeEditorPopoverVarNameOptionsDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSArray *availableVarNames;

- (id) initWithAvailableVarNames:(NSArray *)n;

@end
