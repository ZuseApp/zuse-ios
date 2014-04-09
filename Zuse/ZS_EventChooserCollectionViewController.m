#import "ZS_EventChooserCollectionViewController.h"
#import "ZS_JsonUtilities.h"
#import <MTBlockAlertView/MTBlockAlertView.h>
#import "ZSTutorial.h"

@interface ZS_EventChooserCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel* label;
@end

@implementation ZS_EventChooserCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Cell appearance
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor colorWithRed:0.6 green:0.36 blue:0.38 alpha:1];
        
        // Label
        self.label = [[UILabel alloc] initWithFrame: self.bounds];
        self.label.font = [UIFont systemFontOfSize:16];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
    }
    return self;
}
@end

@interface ZS_EventChooserCollectionViewController ()
@property (nonatomic, strong) NSArray* events;
@end

@implementation ZS_EventChooserCollectionViewController

- (NSArray*) events
{
    if (!_events)
    {
        _events = [ZS_JsonUtilities emptyEvents];
    }
    return _events;
}
- (UICollectionView*) collectionView
{
    UICollectionView *collectionView =[[UICollectionView alloc] initWithFrame: CGRectZero
                                                         collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
    [collectionView registerClass: ZS_EventChooserCollectionViewCell.class
       forCellWithReuseIdentifier: NSStringFromClass([ZS_EventChooserCollectionViewCell class])];
    
    collectionView.userInteractionEnabled = YES;
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    return collectionView;
}
# pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.events.count + 1;
}
- (UICollectionViewCell* )collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ZS_EventChooserCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([ZS_EventChooserCollectionViewCell class]) forIndexPath: indexPath];
    cell.label.text = indexPath.row ? self.events[indexPath.row - 1][@"name"] : @"+";
    return cell;
}
#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MTBlockAlertView *alertView =
        [[MTBlockAlertView alloc] initWithTitle: @"Create New Event Name"
                                        message: @"Please, enter an event name"
                              completionHanlder: ^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             NSString *text = [alertView textFieldAtIndex:0].text;
             if (![text isEqualToString:@""]) {
                 if ([self.json.allKeys[0] isEqualToString:@"on_event"]) {
                     self.json[@"on_event"][@"name"] = text;
                     self.json[@"on_event"][@"parameters"] = [NSMutableArray array];
                 }
                 else if ([self.json.allKeys[0] isEqualToString:@"trigger_event"]) {
                     self.json[@"trigger_event"][@"name"] = text;
                 }
             }
             [self.codeEditorViewController reloadFromJson];
             [self.toolboxView hideAnimated:YES];
         }
                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
    else {
        if ([self.json.allKeys[0] isEqualToString:@"on_event"])
        {
            self.json[@"on_event"][@"name"] = self.events[indexPath.row - 1][@"name"];
            self.json[@"on_event"][@"parameters"] = self.events[indexPath.row - 1][@"parameters"];
        }
        else if ([self.json.allKeys[0] isEqualToString:@"trigger_event"])
        {
            self.json[@"trigger_event"][@"name"] = self.events[indexPath.row - 1][@"name"];
            //self.json[@"trigger_event"][@"parameters"] = self.events[indexPath.row][@"parameters"];
        }
        [self.codeEditorViewController reloadFromJson];
        [self.toolboxView hideAnimated:YES];
    }
    [[ZSTutorial sharedTutorial] broadcastEvent:ZSTutorialBroadcastEventComplete];
}
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name = indexPath.row ? self.events[indexPath.row - 1][@"name"] : @"+";
    CGSize textSize = [name sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    return CGSizeMake(MAX(52, textSize.width + 10), textSize.height + 10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
@end
