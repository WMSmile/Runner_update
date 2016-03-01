//
//  SettingsViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/7/9.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "SettingViewController.h"
#import "PersonInfor.h"
#import "MembersViewController.h"
#import "Constant.h"
#import "HistoryFenceList.h"
#import "OtherSettingViewController.h"
#import "AddWatchViewController.h"
#import "PhoneSettingViewController.h"
#import "HistoryFenceList.h"
#import "HistoryTrackViewController.h"
#import "AlarmSettingView.h"
#import "Networking.h"
#import "Command.h"
@interface SettingViewController ()
{
    UIButton *_personInfor;
    UIButton *_addWatch;
    UIButton *_memberManage;
    UIButton *_phoneSetting;
    UIButton *_alarmSetting;
    UIButton *_fenceSetting;
    UIButton *_histroyManage;
    UIButton *_findWatch;
    UIButton *_closeWatch;
    UIButton *_otherSetting;
    
    UIImageView *portraitView;
    
    UIAlertView *findWatchAlert;
    UIAlertView *closeWatchAlert;
    
    NSString *online;
    NSString *admin;
    NSString *shouhuan_id;
    NSString *clockTime;
    NSString *user_id;
    
    NSArray *clockArray;
    NSArray *switArray;
}
@end

@implementation SettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
        
    [self initUI];
    
    [self initNavigation];
    
}
- (void) viewWillAppear:(BOOL)animated {
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];

    [self updateUI];
    
    online = [[NSUserDefaults standardUserDefaults] objectForKey:@"online"];
    
    admin = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminster"];
}

- (void)initData{
    clockArray = [NSMutableArray new];
    switArray = [NSMutableArray new];
}

- (void)initUI {
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    [self initPersonInfor];
    CGFloat basicX = 21.f;
    CGFloat basicY = 150.f;
    CGFloat basicWidth = (SCREEN_WIDTH - 50) / 3.f;
    CGFloat basicMove = basicWidth + 4.f;
    
    _addWatch = [self buttonWithBackImageName:@"setting_addshouhuan" andPointX:basicX andPointY:basicY];
    [_addWatch addTarget:self action:@selector(addWatch) forControlEvents:UIControlEventTouchUpInside];
    
    _memberManage = [self buttonWithBackImageName:@"member" andPointX:basicX + basicMove andPointY:basicY];
    [_memberManage addTarget:self action:@selector(memberManage) forControlEvents:UIControlEventTouchUpInside];
    
    _phoneSetting = [self buttonWithBackImageName:@"setting_phone" andPointX:basicX + basicMove * 2 andPointY:basicY];
    [_phoneSetting addTarget:self action:@selector(phoneSetting) forControlEvents:UIControlEventTouchUpInside];
    
    _alarmSetting = [self buttonWithBackImageName:@"setting_clock" andPointX:basicX andPointY:basicY + basicMove];
    [_alarmSetting addTarget:self action:@selector(alarmSetting) forControlEvents:UIControlEventTouchUpInside];
    
    _fenceSetting = [self buttonWithBackImageName:@"setting_fence" andPointX:basicX + basicMove andPointY:basicY + basicMove];
    [_fenceSetting addTarget:self action:@selector(fenceSetting) forControlEvents:UIControlEventTouchUpInside];
    
    _histroyManage = [self buttonWithBackImageName:@"historySetting" andPointX:basicX + basicMove * 2 andPointY:basicY + basicMove];
    [_histroyManage addTarget:self action:@selector(histroyManage) forControlEvents:UIControlEventTouchUpInside];
    
    _findWatch = [self buttonWithBackImageName:@"findBra" andPointX:basicX andPointY:basicY + basicMove * 2];
    [_findWatch addTarget:self action:@selector(findWatch) forControlEvents:UIControlEventTouchUpInside];
    
    _closeWatch = [self buttonWithBackImageName:@"off" andPointX:basicX + basicMove andPointY:basicY + basicMove * 2];
    [_closeWatch addTarget:self action:@selector(closeWatch) forControlEvents:UIControlEventTouchUpInside];
    
    _otherSetting = [self buttonWithBackImageName:@"otherSetting" andPointX:basicX + basicMove * 2 andPointY:basicY + basicMove * 2];
    [_otherSetting addTarget:self action:@selector(otherSetting) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)updateUI {
    NSLog(@"updateUI");
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.protrait",shouhuan_id]];
    UIImage *portraitImage = [UIImage imageWithData:imageData];

    [portraitView setImage:portraitImage];
    
    [self initPersonInfor];
}
- (void) initPersonInfor {
    
    CGFloat personInforHeight = 78;
    _personInfor = [[UIButton alloc] initWithFrame:CGRectMake(21 , 70, SCREEN_WIDTH - 42,  personInforHeight)];
    [_personInfor setBackgroundColor:[UIColor whiteColor]];
    [_personInfor.layer setCornerRadius:6.f];
    [_personInfor addTarget:self action:@selector(personInfor) forControlEvents:UIControlEventTouchUpInside];
    
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.protrait",shouhuan_id]];
    UIImage *portraitImage = [UIImage imageWithData:imageData];
    
    portraitView = [[UIImageView alloc] initWithImage:portraitImage];
    portraitView.frame = CGRectMake(8, 8, personInforHeight - 16, personInforHeight - 16);
    
    [portraitView.layer setBorderWidth:0.3f];
    [portraitView.layer setCornerRadius:31];
    [portraitView setClipsToBounds:YES];
    
    [_personInfor addSubview:portraitView];

    
    UIImageView *codeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demensioncode"]];
    codeView.frame = CGRectMake(SCREEN_WIDTH - personInforHeight - 30, 10, personInforHeight - 20, personInforHeight - 20);
    [_personInfor addSubview:codeView];
    
    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(personInforHeight, 18, SCREEN_WIDTH - personInforHeight * 2.5, personInforHeight/2)];
    
    
    NSString *shouhuan_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_name"];
    
    NSLog(@"shouhuna_name : %@",shouhuan_name);
    
    [remarkLabel setText:shouhuan_name];
    [remarkLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_personInfor addSubview:remarkLabel];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(personInforHeight, personInforHeight/2 + 10, SCREEN_WIDTH - personInforHeight * 2.5, personInforHeight / 4)];
    
    NSString *step_num = [[NSUserDefaults standardUserDefaults] objectForKey:@"step_num"];
    [countLabel setText:[NSString stringWithFormat:@"计步数:%@",step_num]];
    [countLabel setTextAlignment:NSTextAlignmentCenter];
    [countLabel setFont:[UIFont systemFontOfSize:14]];
    
    [_personInfor addSubview:countLabel];
    
    [self.view addSubview:_personInfor];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    
    
    NSLog(@"shouhuan_id : %@",shouhuan_id );
    
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
        
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
            
            clockTime = [jsonDict objectForKey:@"clock"];
            
            if (clockTime.length > 0) {
                NSRange range1 = {0,5};
                NSRange range2 = {10,5};
                NSRange range3 = {20,5};
                
                NSRange range_1 = {6,1};
                NSRange range_2 = {16,1};
                NSRange range_3 = {26,1};
                
                NSString *time_1 = [clockTime substringWithRange:range1];
                NSString *time_2 = [clockTime substringWithRange:range2];
                NSString *time_3 = [clockTime substringWithRange:range3];
                
                NSString *swit1 = [clockTime substringWithRange:range_1];
                NSString *swit2 = [clockTime substringWithRange:range_2];
                NSString *swit3 = [clockTime substringWithRange:range_3];
                
                clockArray = [NSMutableArray arrayWithObjects:time_1,time_2,time_3,nil];
                
                switArray = [NSMutableArray arrayWithObjects:swit1,swit2,swit3,nil];
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

- (void)initNavigation {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"管理";
    self.navigationItem.titleView= titleLabel;
}

- (void)personInfor {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }
    PersonInfor *personInfor = [PersonInfor new];
    [personInfor setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:personInfor animated:YES];
}
- (void)addWatch {
    AddWatchViewController *addWatch = [AddWatchViewController new];
    [addWatch setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:addWatch animated:YES];
}
- (void)memberManage {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    MembersViewController *members = [MembersViewController new];
    [members setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:members animated:YES];
}
- (void)phoneSetting {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    if ([online isEqualToString:@"0"]) {
        [self showAlertWatchOffLine];
        return;
    }
    if ([admin isEqualToString:@"0"]) {
        [self showAlertNoPower];
        return;
    }
    PhoneSettingViewController *phoneSetting = [PhoneSettingViewController new];
    
    [phoneSetting setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:phoneSetting animated:YES];
}
- (void)alarmSetting {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    if ([online isEqualToString:@"0"]) {
        [self showAlertWatchOffLine];
        return;
    }
    
    if ([admin isEqualToString:@"0"]) {
        [self showAlertNoPower];
        return;
    }
    AlarmSettingView *alarmSetting = [AlarmSettingView new];
    [alarmSetting setHidesBottomBarWhenPushed:YES];
    alarmSetting.alarmArray = clockArray;
    alarmSetting.switsState = switArray;
    [self.navigationController pushViewController:alarmSetting animated:YES];
}
- (void)fenceSetting {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    HistoryFenceList *fenceList = [HistoryFenceList new];
    [fenceList setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:fenceList animated:YES];
}
- (void)histroyManage {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    HistoryTrackViewController *fenceList = [HistoryTrackViewController new];
    [fenceList setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:fenceList animated:YES];
}
- (void)findWatch {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    if ([online isEqualToString:@"0"]) {
        [self showAlertWatchOffLine];
        return;
    }
    if ([admin isEqualToString:@"0"]) {
        [self showAlertNoPower];
        return;
    }
    findWatchAlert = [[UIAlertView alloc] initWithTitle:@"手环将发出声音" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [findWatchAlert show];
}
- (void)closeWatch {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    if ([online isEqualToString:@"0"]) {
        [self showAlertWatchOffLine];
        return;
    }
    if ([admin isEqualToString:@"0"]) {
        [self showAlertNoPower];
        return;
    }
    closeWatchAlert = [[UIAlertView alloc] initWithTitle:@"手环将要关闭" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [closeWatchAlert show];
}
- (void)otherSetting {
    if (!shouhuan_id) {
        [self showAlertNoWatch];
        return;
    }

    OtherSettingViewController *otherSetting = [OtherSettingViewController new];
    [otherSetting setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:otherSetting animated:YES];
}
- (UIButton *)buttonWithBackImageName:(NSString *)imageName andPointX:(CGFloat)x andPointY:(CGFloat)y{
    CGFloat width = (SCREEN_WIDTH - 50) / 3;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, width)];
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    NSString *buttonPress = [NSString stringWithFormat:@"%@_press",imageName];
    UIImage *buttonPressImage = [UIImage imageNamed:buttonPress];
    [button setBackgroundImage:buttonPressImage forState:UIControlStateHighlighted];
    
    [button.layer setBorderColor:[UIColor grayColor].CGColor];
    [button.layer setBorderWidth:0.3f];
    [button.layer setCornerRadius:9.f];
    
    [self.view addSubview:button];
    
    return button;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    
    if (alertView == findWatchAlert) {
        [Command commandWithName:@"FIND" andParameter:@"0"];
    }
    if (alertView == closeWatchAlert) {
        [Command commandWithName:@"POWEROFF" andParameter:@"POWEROFF"];
    }
}

- (void)showAlertWatchOffLine{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手环不在线" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}
         
- (void)showAlertNoPower{
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您不是管理员，没有权限" message:nil delegate:self
                                                 cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)showAlertNoWatch{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未绑定手环" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
