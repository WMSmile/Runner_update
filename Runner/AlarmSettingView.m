//
//  AlarmSettingView.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/10.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "AlarmSettingView.h"
#import "Constant.h"
#import "Command.h"
#import "IQActionSheetPickerView.h"
@interface AlarmSettingView()<IQActionSheetPickerViewDelegate>
{
    UIButton *firstAlarm;
    UIButton *secondAlarm;
    UIButton *thirdAlarm;
    UIButton *selectedAlarm;
    
    UIButton *sureButton;
    
    UISwitch *swits[3];
    NSMutableArray *switsState;
    NSMutableArray *alarmArray;
    
    NSString *firstOn;
    NSString *secondOn;
    NSString *thirdOn;
    
    //timepicker
    IQActionSheetPickerView *picker;
}

@end
@implementation AlarmSettingView
@synthesize alarmArray,switsState;
- (void)viewDidLoad{
    NSLog(@"viewdidlocad");
    
    [super viewDidLoad];
    
    [self initDatePicker];
    [self initData];
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)initDatePicker {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    picker = [[IQActionSheetPickerView alloc] initWithTitle:@"选择时间" delegate:self];
    [picker setTag:8];
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleTimePicker];
}

- (void)initData {
    if (!switsState) {
        switsState = [NSMutableArray arrayWithObjects:@"0",@"0",@"0", nil];
    }
    NSLog(@"SWITSSTATE:%@",switsState);
    if (!alarmArray) {
        alarmArray = [NSMutableArray arrayWithObjects:@"00:00",@"00:00",@"00:00", nil];
    }
    NSLog(@"alrarmArray : %@",alarmArray);
}
- (void)initUI {
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    CGFloat basicY = 70;
    CGFloat basicMove = 54;
    
    firstAlarm = [self buttonWthName:@"08:00   " andPointY:basicY];
    
    secondAlarm = [self buttonWthName:@"19:00   " andPointY:basicY + basicMove];
    
    thirdAlarm = [self buttonWthName:@"00:00   " andPointY:basicMove * 2 + basicY];
    
    sureButton = [self buttonWthName:@"确定" andPointY:0];
    [sureButton setFrame:CGRectMake(6, basicY + basicMove * 4, SCREEN_WIDTH - 12, 36)];
    [sureButton addTarget:self action:@selector(clickSureButton) forControlEvents:UIControlEventTouchUpInside];
}
- (UIButton *)buttonWthName:(NSString *)name andPointY:(CGFloat)y {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6, y, SCREEN_WIDTH - 12, 50)];
    [button setTag:(y - 70) / 54];
    [button setBackgroundColor:[UIColor whiteColor]];
    
    [button setTitle:name forState:UIControlStateNormal];
    [button setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [button.layer setCornerRadius:6.f];
    [button.layer setBorderColor:[UIColor grayColor].CGColor];
    [button.layer setBorderWidth:0.3f];
    

    if (y != 0) {
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];

        UISwitch *swit = [UISwitch new];
        [swit setFrame:CGRectMake(SCREEN_WIDTH - 12 - 60, 3, 10, 40)];
        [swit setOnTintColor:DEFAULTCOLOR];
        
        [swit addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventTouchUpInside];
        
        [button addSubview:swit];
        
        int i = (y - 70)/54;
        swits[i] = swit;
        [swit setTag:i];
        
        if ([[switsState objectAtIndex:i] isEqualToString:@"1"]) {
            [swit setOn:YES animated:NO];

        }else {
            [swit setOn:NO animated:NO];
        }
        if ([alarmArray objectAtIndex:i]) {
            [button setTitle:[alarmArray objectAtIndex:i] forState:UIControlStateNormal];
        }
    }
    [self.view addSubview:button];

    return button;
}
- (void)clickButton:(UIButton *)btn {
    NSLog(@"%ld",(long)btn.tag);
    selectedAlarm = btn;
    [picker show];
}

- (void)clickSwitch:(UISwitch *)sender{
    if (sender.isOn) {
        NSLog(@"%@",switsState);
        
        [switsState replaceObjectAtIndex:sender.tag withObject:@"1"];
    }
    if (!sender.isOn) {
        NSLog(@"%@",switsState);
        [switsState replaceObjectAtIndex:sender.tag withObject:@"0"];
    }
}

- (void)clickSureButton {
    NSString *parameter = [NSString stringWithFormat:@"%@-%@-2,%@-%@-2,%@-%@-2",firstAlarm.titleLabel.text,[switsState objectAtIndex:0],secondAlarm.titleLabel.text,[switsState objectAtIndex:1],thirdAlarm.titleLabel.text,[switsState objectAtIndex:2]];
    
    NSLog(@"parameter : %@",parameter);
    
    [Command commandWithName:@"REMIND" andParameter:parameter];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    switch (pickerView.tag)
    {
        case 8:
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterNoStyle];
            formatter.dateFormat = @"HH:mm";

            [selectedAlarm setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end
