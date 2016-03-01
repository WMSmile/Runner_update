//
//  VerifyViewController.m
//  SMS_SDKDemo
//
//  Created by admin on 14-6-4.
//  Copyright (c) 2014年 admin. All rights reserved.
//

#import "VerifyViewController.h"
#import "Constant.h"
#import "ForgetPasswordViewController.h"

#import <AddressBook/AddressBook.h>

#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/SMSSDKUserInfo.h>
#import <SMS_SDK/SMSSDKAddressBook.h>
#import <SMS_SDK/SMSSDK+DeprecatedMethods.h>

@interface VerifyViewController ()
{
    NSString* _phone;
    NSString* _areaCode;
    int _state;
    NSMutableData* _data;
    NSString* _localVerifyCode;
    
    NSString* _appKey;
    NSString* _appSecret;
    NSString* _duid;
    NSString* _token;
    NSString* _localPhoneNumber;
    
    NSString* _localZoneNumber;
    NSMutableArray* _addressBookTemp;
    NSString* _contactkey;
    SMSSDKUserInfo* _localUser;
    
    NSTimer* _timer3;
    
    UIAlertView* _alert2;
    UIAlertView* _alert3;
}

@end

//最近新好友信息
static NSMutableArray* _userData2;

@implementation VerifyViewController

-(void)clickLeftButton
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                  message:NSLocalizedString(@"codedelaymsg", nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"back", nil)
                                        otherButtonTitles:NSLocalizedString(@"wait", nil), nil];
    _alert2 = alert;
    [alert show];    
}

-(void)setPhone:(NSString*)phone AndAreaCode:(NSString*)areaCode
{
    _phone = phone;
    _areaCode = areaCode;
}

-(void)submit
{
    //验证号码
    //验证成功后 获取通讯录 上传通讯录
    [self.view endEditing:YES];
    
    if(self.verifyCodeField.text.length != 4)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"验证码错误"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [SMSSDK commitVerificationCode:self.verifyCodeField.text phoneNumber:_phone zone:_areaCode result:^(NSError *error) {
            
            if (!error) {
                ForgetPasswordViewController *forget = [ForgetPasswordViewController new];
                [self presentViewController:forget animated:YES completion:^{
                    ;
                }];
                
                
            }
            else
            {
                NSLog(@"验证失败");
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"验证失败"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            
            }
        }];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _alert2) {
        if (0 == buttonIndex)
        {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat statusBarHeight = 0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight = 20;
    }
    
    [self initNavigation];
    
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 53+statusBarHeight, self.view.frame.size.width - 30, 21);
    label.text = [NSString stringWithFormat:@"验证码已经发送到:"];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:label];
    
    _telLabel = [[UILabel alloc] init];
    _telLabel.frame=CGRectMake(15, 82+statusBarHeight, self.view.frame.size.width - 30, 21);
    _telLabel.textAlignment = NSTextAlignmentCenter;
    _telLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self.view addSubview:_telLabel];
    self.telLabel.text = [NSString stringWithFormat:@"+%@ %@",_areaCode,_phone];
    
    _verifyCodeField = [[UITextField alloc] init];
    _verifyCodeField.frame = CGRectMake(15, 111+statusBarHeight, self.view.frame.size.width - 30, 46);
    _verifyCodeField.borderStyle = UITextBorderStyleBezel;
    _verifyCodeField.textAlignment = NSTextAlignmentCenter;
    _verifyCodeField.placeholder = @"输入验证码";
    _verifyCodeField.font = [UIFont fontWithName:@"Helvetica" size:18];
    _verifyCodeField.keyboardType = UIKeyboardTypePhonePad;
    _verifyCodeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:_verifyCodeField];
//    
//    _timeLabel = [[UILabel alloc] init];
//    _timeLabel.frame = CGRectMake(15, 169+statusBarHeight, self.view.frame.size.width - 30, 40);
//    _timeLabel.numberOfLines = 0;
//    _timeLabel.textAlignment = NSTextAlignmentCenter;
//    _timeLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
//    _timeLabel.text = NSLocalizedString(@"timelabel", nil);
//    [self.view addSubview:_timeLabel];
//    
//    _repeatSMSBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    _repeatSMSBtn.frame = CGRectMake(15, 169+statusBarHeight, self.view.frame.size.width - 30, 30);
//    [_repeatSMSBtn setTitle:NSLocalizedString(@"repeatsms", nil) forState:UIControlStateNormal];
//    [_repeatSMSBtn addTarget:self action:@selector(CannotGetSMS) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_repeatSMSBtn];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitBtn setBackgroundColor:DEFAULTCOLOR];
    
    _submitBtn.frame = CGRectMake(15, 220 + statusBarHeight, self.view.frame.size.width - 30, 42);
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];

}
- (void)initNavigation{
    CGFloat statusBarHeight=0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight=20;
        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        [self.view addSubview:statusView];
        
        [statusView setBackgroundColor:DEFAULTCOLOR];
    }
    
    //创建一个导航栏
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0+statusBarHeight, self.view.frame.size.width, 44)];
    
    [navigationBar setBarTintColor:DEFAULTCOLOR];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(clickLeftButton)];
    [leftButton setTintColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [titleLabel setText:@"注册账号"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [navigationItem setTitleView:titleLabel];
    
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem setLeftBarButtonItem:leftButton];
    
    
    [self.view addSubview:navigationBar];
    
}


//-(void)updateTime
//{
//    count++;
//    if (count >= 60)
//    {
//        [_timer2 invalidate];
//        return;
//    }
//    //NSLog(@"更新时间");
//    self.timeLabel.text = [NSString stringWithFormat:@"%@%i%@",NSLocalizedString(@"timelablemsg", nil),60-count,NSLocalizedString(@"second", nil)];
//    
//    if (count == 30)
//    {
//        if (_voiceCallMsgLabel.hidden)
//        {
//            _voiceCallMsgLabel.hidden = NO;
//        }
//        
//        if (_voiceCallButton.hidden)
//        {
//            _voiceCallButton.hidden = NO;
//        }
//    }
//}


@end
