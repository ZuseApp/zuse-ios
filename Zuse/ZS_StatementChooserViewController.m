#import "ZS_StatementChooserViewController.h"
#import "ZS_StatementView.h"

@interface ZS_StatementChooserViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *statementPicker;
@end

@implementation ZS_StatementChooserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.statementPicker.delegate = self;
    self.statementPicker.dataSource = self;
    
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    ZS_StatementView* statement = [[ZS_StatementView alloc]initWithJson:nil];
 
    
    if (row == 0)
    {
        [statement addNameLabelWithText:@"  ON EVENT"];
        [statement addArgumentLabelWithText:@"#event name" touchBlock:nil];
    }
    else if (row == 1)
    {
        [statement addNameLabelWithText:@"  TRIGGER EVENT"];
        [statement addArgumentLabelWithText:@"#event name" touchBlock:nil];
    }
    else if (row == 2)
    {
        [statement addNameLabelWithText:@"  IF"];
        [statement addArgumentLabelWithText:@"#expression" touchBlock:nil];
    }
    else if (row == 3)
    {
        [statement addNameLabelWithText:@"  SET"];
        [statement addArgumentLabelWithText:@"#name" touchBlock:nil];
        [statement addNameLabelWithText:@"TO"];
        [statement addArgumentLabelWithText:@"#value" touchBlock:nil];
    }
    else if (row == 4)
    {
        [statement addNameLabelWithText:@"  MOVE ("];
        [statement addArgumentLabelWithText:@"#var" touchBlock:nil];
        [statement addNameLabelWithText:@","];
        [statement addArgumentLabelWithText:@"#var" touchBlock:nil];
        [statement addNameLabelWithText:@")"];
    }
    return statement;
}
- (IBAction)doneButtonTouched
{
    self.didFinish([self.statementPicker selectedRowInComponent:0]);
}
- (IBAction)cancelButtonTouched
{
    self.didFinish(-1);
}
@end
