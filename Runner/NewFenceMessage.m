//
//  NewFenceMessage.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/24.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "NewFenceMessage.h"
#import "Constant.h"
#import "IQActionSheetPickerView.h"
#import "Networking.h"
#define BASIC_HEIGHT 36
#define BASIC_SPACE 4
#define BASIC_DISTANCE 40

@interface NewFenceMessage()<IQActionSheetPickerViewDelegate>
{
    UITextField *fenceNameTextField;
    
    UIButton *inButton;
    UIButton *outButton;
    UIButton *inAndOutButton;
    
    UIButton *selectedButton;
    
    UIButton *startButton;
    UIButton *endButton;
    
    IQActionSheetPickerView *picker;
    
    NSString *type;
    NSString *fencename;
    NSString *time;
}

@end

@implementation NewFenceMessage
@synthesize fence;
@synthesize fencesArray;
-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self initUI];
    
    [self initDatePicker];
    
    NSLog(@"%@",self.fence);
}

- (void)initData{
    type = @"1";
}

- (void)initUI {
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    //围栏姓名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, SCREEN_WIDTH - 20, BASIC_HEIGHT)];
    [nameLabel setText:@"输入围栏名称"];
    [nameLabel setTextColor:[UIColor blackColor]];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:nameLabel];
    
    fenceNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70 + BASIC_HEIGHT + BASIC_SPACE, SCREEN_WIDTH - 20,BASIC_HEIGHT)];
    [fenceNameTextField setPlaceholder:@"如学校，家，公园"];
    [fenceNameTextField setTextAlignment:NSTextAlignmentCenter];
    
    
    UIView *lineview = [[UIView alloc] initWithFrame:CGRectMake(40, 70 + BASIC_DISTANCE * 2 , SCREEN_WIDTH - 80, 1)];
    [lineview setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:lineview];
    
    [self.view addSubview:fenceNameTextField];
    
    //进出警告
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70 + BASIC_DISTANCE * 2, SCREEN_WIDTH - 20, BASIC_HEIGHT)];
    [typeLabel setTextAlignment:NSTextAlignmentCenter];
    [typeLabel setText:@"围栏进出警告"];
    [typeLabel setTextColor:DEFAULTCOLOR];
    
    [self.view addSubview:typeLabel];
    
    inButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 70 + BASIC_DISTANCE * 3, (SCREEN_WIDTH - 20)  / 3, BASIC_HEIGHT)];
    [inButton setTitle:@"进去警告" forState:(UIControlStateNormal)];
    [inButton setTag:1];
    [inButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [inButton setTitleColor:DEFAULTCOLOR forState:UIControlStateSelected];
    [inButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [inButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [inButton setSelected:YES];
    [inButton addTarget:self action:@selector(chooseAlarmType:) forControlEvents:UIControlEventTouchUpInside];
    
    outButton = [[UIButton alloc] initWithFrame:CGRectMake(10 + (SCREEN_WIDTH - 20)  / 3, 70 + BASIC_DISTANCE * 3, (SCREEN_WIDTH - 20)  / 3, BASIC_HEIGHT)];
    [outButton setTitle:@"离开警告" forState:UIControlStateNormal];
    [outButton setTag:2];
    [outButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [outButton setTitleColor:DEFAULTCOLOR forState:UIControlStateSelected];
    [outButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [outButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [outButton addTarget:self action:@selector(chooseAlarmType:) forControlEvents:UIControlEventTouchUpInside];
    
    inAndOutButton = [[UIButton alloc] initWithFrame:CGRectMake(10 + (SCREEN_WIDTH - 20)  / 3 * 2, 70 + BASIC_DISTANCE * 3, (SCREEN_WIDTH - 20)  / 3, BASIC_HEIGHT)];
    [inAndOutButton setTitle:@"进出警告" forState:UIControlStateNormal];
    [inAndOutButton setTag:3];
    [inAndOutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [inAndOutButton setTitleColor:DEFAULTCOLOR forState:UIControlStateSelected];
    [inAndOutButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [inAndOutButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [inAndOutButton addTarget:self action:@selector(chooseAlarmType:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:inButton];
    [self.view addSubview:outButton];
    [self.view addSubview:inAndOutButton];
    
    UIView *lineview_1 = [[UIView alloc] initWithFrame:CGRectMake(20, 70 + BASIC_DISTANCE * 4, SCREEN_WIDTH- 40, 1)];
    [lineview_1 setBackgroundColor:DEFAULTCOLOR];
    [self.view addSubview:lineview_1];
    
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70 + BASIC_DISTANCE * 4, SCREEN_WIDTH / 2 - 20, BASIC_HEIGHT)];
    [startLabel setTextAlignment:NSTextAlignmentCenter];
    [startLabel setTextColor:[UIColor blackColor]];
    [startLabel setText:@"监护起始时间"];
    [startLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self.view addSubview:startLabel];
    
    UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 10, 70 + BASIC_DISTANCE * 4, SCREEN_WIDTH / 2 - 20, BASIC_HEIGHT)];
    [endLabel setTextAlignment:NSTextAlignmentCenter];
    [endLabel setTextColor:[UIColor blackColor]];
    [endLabel setText:@"监护结束时间"];
    [endLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self.view addSubview:endLabel];
    
    startButton = [[UIButton alloc] initWithFrame:CGRectMake(0,70 + BASIC_DISTANCE * 5, SCREEN_WIDTH / 2 - 20, BASIC_HEIGHT)];
    [startButton setTitle:@"00:00" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(chooseGuardTime:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:startButton];
    
    endButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 10, 70 + BASIC_DISTANCE * 5, SCREEN_WIDTH / 2 - 20, BASIC_HEIGHT)];
    [endButton setTitle:@"11:00" forState:UIControlStateNormal];
    [endButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [endButton addTarget:self action:@selector(chooseGuardTime:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:endButton];
    
    UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 70 + BASIC_DISTANCE * 7, SCREEN_WIDTH - 20, BASIC_HEIGHT)];
    [sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [sureButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [sureButton.layer setBorderWidth:0.3];
    [sureButton.layer setCornerRadius:6.f];
    
    [sureButton addTarget:self action:@selector(clickSureButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sureButton];
    
}

- (void)initDatePicker {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    picker = [[IQActionSheetPickerView alloc] initWithTitle:@"选择时间" delegate:self];
    [picker setTag:8];
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleTimePicker];
}


- (void)chooseAlarmType:(UIButton *)sender {
    [sender setSelected:YES];
    if (sender.tag == 1) {
        outButton.selected = NO;
        inAndOutButton.selected = NO;
    }
    if (sender.tag == 2) {
        inAndOutButton.selected = NO;
        inButton.selected = NO;
    }
    if (sender.tag == 3) {
        inButton.selected = NO;
        outButton.selected = NO;
    }
    type = [NSString stringWithFormat:@"%ld",(long)sender.tag];

}

- (void)chooseGuardTime:(UIButton *)sender{
    selectedButton = sender;
    [picker show];
}

- (void)clickSureButton{
    fencename = fenceNameTextField.text;
    
    if (!fencename) {
        NSLog(@"输入围栏姓名不能为空");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入围栏名称为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if ([self.fencesArray containsObject:fencename]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入围栏名称重复" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *startTime = [dateFormatter dateFromString:startButton.titleLabel.text];
    
    NSDate *endTime = [dateFormatter dateFromString:endButton.titleLabel.text];
    
    if ([endTime compare:startTime] == NSOrderedAscending) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择时间不正确" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    };
    
    time = [NSString stringWithFormat:@"%@ - %@",startButton.titleLabel.text,endButton.titleLabel.text];
        
    NSLog(@"%@ %@ %@ %@ %@",fencename,fence.user_id,time,type,fence.fence);
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSDictionary *parameters = @{
                                 @"fence":fence.fence,
                                 @"fence_name":fencename,
                                 @"shouhuan_id":fence.shouhuan_id,
                                 @"time":time,
                                 @"type":type,
                                 @"user_id":fence.user_id
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/fence";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        if ([code isEqualToString:@"200"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"200" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if ([code isEqualToString:@"500"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"500" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        NSLog(@"操作失败");
    }];

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
            [selectedButton setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
