//
//  ZS_StatementChooserViewController.h
//  New Code Editor
//
//  Created by Vladimir on 2/19/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZS_StatementChooserViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (copy, nonatomic) void(^didFinish)(NSInteger statementType);
@end
