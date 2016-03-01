//
//  NoDisturbingTime.m
//  爱之心
//
//  Created by 于恩聪 on 15/10/4.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "NoDisturbingTime.h"
#import "IQActionSheetPickerView.h"

#import "Command.h"

#import "Constant.h"

#import "Networking.h"



@interface NoDisturbingTime()<IQActionSheetPickerViewDelegate>
{
    CGFloat basicX;
    CGFloat basicY;
    CGFloat basicMove;
    
    IQActionSheetPickerView *picker;
    
    NSMutableArray *contentArray;
    UIButton *buttons[8];
    UIButton *selectedButton;
    
    NSString *paramater;
    
    NSString *user_id;
    NSString *shouhuan_id;
    
    NSString *nodisturbTime;
    
    NSArray *timeArray;
}

@end
@implementation NoDisturbingTime

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initData];

    [self initUI];
    
    [self getWatchMessage];
}

- (void)initData{
    basicMove = 50;
    
    basicY = 70;
    
    contentArray = [NSMutableArray arrayWithObjects:@"时间段1",@"时间段2",@"时间段3",@"时间段4",nil];
    
    picker = [[IQActionSheetPickerView alloc] initWithTitle:@"选择时间" delegate:self];
    [picker setTag:8];
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleTimePicker];
    
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
}
- (void)getWatchMessage{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSLog(@"user_id :%@ shouhuan_id : %@",user_id,shouhuan_id);
    
    if (!user_id || !shouhuan_id) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/shouhuan";
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        NSString *data = [dict objectForKey:@"data"];
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        NSLog(@"data:%@",jsonDict);
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            
            nodisturbTime = [jsonDict objectForKey:@"silencetime"];
            
            nodisturbTime = [nodisturbTime stringByReplacingOccurrencesOfString:@"-" withString:@","];
            
            timeArray = [nodisturbTime componentsSeparatedByString:@","];
            
            NSLog(@"array : %@",timeArray);
            
            NSLog(@"nodisturbtime : %@",nodisturbTime);
            
            for (int i = 0; i < 8 && i < timeArray.count; i++) {
                if (![[timeArray objectAtIndex:i] isEqualToString:@""]) {
                    [buttons[i] setTitle:[timeArray objectAtIndex:i] forState:UIControlStateNormal];
                }
            }
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
        NSLog(@"操作失败");
    }];

}

- (void)initUI{
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 70, SCREEN_WIDTH, 40)];
    
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [titleLabel setText:@"温馨提示:宝贝正在学习，请勿打扰"];
    
    [titleLabel setTextColor:[UIColor blackColor]];
    
    [titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    [self.view addSubview:titleLabel];

    [self initViewWithPointY:basicY + basicMove andTag:0];
    
    [self initViewWithPointY:basicY + basicMove * 2 andTag:1];
    
    [self initViewWithPointY:basicY + basicMove * 3 andTag:2];
    
    [self initViewWithPointY:basicY + basicMove * 4 andTag:3];
    
    UIButton *sureButton = [[UIButton alloc] initWithFrame:CGRectMake(6, basicMove * 5 + basicY, SCREEN_WIDTH - 12, 40)];
    
    [sureButton setBackgroundColor:[UIColor whiteColor]];
    
    [sureButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [sureButton.layer setBorderWidth:0.3f];
    [sureButton.layer setCornerRadius:6.f];
    
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
    [sureButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:sureButton];
    
    [sureButton addTarget:self action:@selector(clickSureButton) forControlEvents:UIControlEventTouchUpInside];

}

- (void)initViewWithPointY:(CGFloat)y andTag:(NSInteger)tag{
    //第一个
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(6, y, SCREEN_WIDTH - 12, 40)];
    
    [view setUserInteractionEnabled:YES];
    
    [view setBackgroundColor:[UIColor whiteColor]];
    
    [view.layer setBorderColor:[UIColor grayColor].CGColor];
    
    [view.layer setBorderWidth:0.3f];

    [view.layer setCornerRadius:6.f];
    
    [view setClipsToBounds:YES];
    
    //时间段
    UILabel *firstlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 3 - 4, 40)];
    
    [firstlabel setTextColor:[UIColor blackColor]];
    
    [firstlabel setText:[contentArray objectAtIndex:(y - basicY) / basicMove - 1]];
    
    [firstlabel setTextAlignment:NSTextAlignmentCenter];
    
    [view addSubview:firstlabel];
    
    //第一个button
    
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 3 - 4,0 ,( SCREEN_WIDTH / 3 - 4 ) * 2, 40)];
    [secondLabel setUserInteractionEnabled:YES];
    [secondLabel setText:@":"];
    
    [secondLabel setTextColor:[UIColor blackColor]];
    
    [secondLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    UIButton *firstButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH / 3 - 6, 40)];
    
    [firstButton setTitle:@"00:00" forState:UIControlStateNormal];
    
    [firstButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [firstButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [firstButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    buttons[(int)((y - basicY)/basicMove*2 - 2)] = firstButton;
    
    [secondLabel addSubview:firstButton];
    
    //第二个buttton
    
    UIButton *secondButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 3 - 2,0, SCREEN_WIDTH / 3 - 4, 40)];
    
    [secondButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [secondButton setTitle:@"00:00" forState:UIControlStateNormal];
    
    [secondButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [secondButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    buttons[(int)((y - basicY)/basicMove*2 - 1)] = secondButton;
    
    [secondLabel addSubview:secondButton];
    
    [view addSubview:secondLabel];
    
    [self.view addSubview:view];
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
            [selectedButton setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
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


- (void)clickButton:(UIButton *)sender{
    NSLog(@"clickTimeButton");
    
    selectedButton = sender;
    
    [picker show];
}

- (void)clickSureButton{
    paramater = [NSString new];
    for (int i = 1; i < 5; i ++) {
        NSString *firstTitle = buttons[i*2 - 2].titleLabel.text;
        
        NSString *secondTitle = buttons[i*2 - 1].titleLabel.text;
        
        NSLog(@"firstTitle : %@",firstTitle);
        
        NSLog(@"secondTitle : %@",secondTitle);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSDate *startTime = [dateFormatter dateFromString:firstTitle];
        
        NSDate *endTime = [dateFormatter dateFromString:secondTitle];
        
        if ([endTime compare:startTime] == NSOrderedAscending) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择时间不正确" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        };
        
        paramater = [NSString stringWithFormat:@"%@,%@-%@",paramater,firstTitle,secondTitle];

    }
    NSRange range = {1,paramater.length - 1};
    
    paramater = [paramater substringWithRange:range];
    
    NSLog(@"paramater : %@",paramater);
    
    [Command commandWithName:@"SILENCETIME" andParameter:paramater];
}

@end
