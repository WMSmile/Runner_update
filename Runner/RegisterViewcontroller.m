//
//  RegisterViewcontroller.m
//  爱之心
//
//  Created by 于恩聪 on 15/11/3.
//  Copyright © 2015年 于恩聪. All rights reserved.
//

#import "RegisterViewcontroller.h"
#import "Constant.h"
#import "VerifyViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/SMSSDK+ExtexdMethods.h>
#import "Networking.h"

@interface RegisterViewcontroller()<UITextFieldDelegate,UIAlertViewDelegate>
{
    UIButton *delegateButton;
    
    
    UITextView *delegateTextView;
    
    UITextField *phnumTextField;
    UITextField *identCodeTextField;
    UITextField *emailTextFiled;
    UITextField *pswdTextField;
    
    //code
    
    NSMutableArray* _areaArray;
    NSString* _defaultCode;
    NSString* _defaultCountryName;

    NSString *_str;
    
    BOOL codeIsRight;
    
}

@end

@implementation RegisterViewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    
    [self initUi];
}

- (void)initData{
    _areaArray = [NSMutableArray array];
    
    //设置本地区号
    [self setTheLocalAreaCode];
    //获取支持的地区列表
    [SMSSDK getCountryZone:^(NSError *error, NSArray *zonesArray) {
        
        if (!error) {
            
            NSLog(@"get the area code sucessfully");
            //区号数据
            _areaArray = [NSMutableArray arrayWithArray:zonesArray];
            //            NSLog(@"_areaArray_%@",_areaArray);
            
        }
        else
        {
            
            NSLog(@"failed to get the area code _%@",[error.userInfo objectForKey:@"getZone"]);
            
        }
        
    }];
}

- (void)initUi{
    self.view.backgroundColor=DEFAULT_BACKGOUNDCOLOR;

    [self initNavigation];
    [self initTextField];
    [self initRegButton];
    [self initGetCodeButton];
    [self initDelegate];
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
- (void)initDelegate {
    delegateButton = [[UIButton alloc] initWithFrame:CGRectMake(18, 238 + 50 , SCREEN_WIDTH - 12, 12)];
    
    [delegateButton setTitle:@"阅读并接受《【爱之心】用户协议》" forState:UIControlStateNormal];
    [delegateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [delegateButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    [delegateButton addTarget:self action:@selector(showDelegate) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: delegateButton];
    
    delegateTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [delegateTextView setBackgroundColor:[UIColor whiteColor]];
    [delegateTextView setFont:[UIFont systemFontOfSize:20]];
    [delegateTextView setText:@"  （双击 退出）11111111111嘿嘿，看到这个题目，相信部分读者会问，你前面的Fragment写完了吗？嗯，没写完，因为想例子，需要 一点时间，为了提高效率，所以决定像多线程一样，并发的来写教程，这样可能可以加快写教程的进度， 到现在为止，刚好写了60篇.离完成入门教程还很远呢，而前面也说过，想在一个半到两个月之内完成 这套教程，今天已经9.1号了，要加吧劲~好的，废话就这么多，本节给大家介绍的是Android数据存储与 访问方式中的一个——文件存储与读写，当然除了这种方式外，我们可以存到SharedPreference，数据库， 或者Application中，当然这些后面都会讲，嗯，开始本节内容~"];
    [delegateTextView setTintColor:[UIColor grayColor]];
    
    delegateTextView.scrollEnabled = YES;
    delegateTextView.editable = NO;
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [delegateTextView addGestureRecognizer:doubleTapGestureRecognizer];
    
    [delegateTextView setHidden:YES];
    
    [self.view addSubview:delegateTextView];
}
- (void)initRegButton{
    UIButton *registButton=[[UIButton alloc] initWithFrame:CGRectMake(6.f, 238.0f, SCREEN_WIDTH-12, 36.f)];
    registButton.layer.borderColor=[UIColor grayColor].CGColor;
    registButton.layer.borderWidth=0.3f;
    registButton.layer.cornerRadius=6.f;
    
    [registButton setTitle:@"注册" forState:UIControlStateNormal];
    [registButton.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
    
    [registButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [registButton setBackgroundColor:[UIColor whiteColor]];
    [registButton addTarget:self action:@selector(userRegist) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registButton];
    
}

- (void)initGetCodeButton{
    UIButton *codeButton =[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 106.f, 112.f, 100.f, 36.f)];
    
    codeButton.layer.borderColor=[UIColor grayColor].CGColor;
    codeButton.layer.borderWidth=0.3f;
    codeButton.layer.cornerRadius=6.f;
    
    [codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [codeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [codeButton setBackgroundColor:[UIColor whiteColor]];
    [codeButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:codeButton];

}

-(void)initTextField{
    //手机号码
    
    phnumTextField =[[UITextField alloc]initWithFrame:CGRectMake(6.f, 70,SCREEN_WIDTH-12, 36.f)];
    phnumTextField.delegate= self;
    phnumTextField.backgroundColor=[UIColor whiteColor];
    phnumTextField.keyboardType=UIKeyboardTypeDecimalPad;
    phnumTextField.returnKeyType=UIReturnKeyDone;
    phnumTextField.placeholder=@"手机号码";
    phnumTextField.layer.borderWidth=0.3f;
    phnumTextField.layer.borderColor=[UIColor grayColor].CGColor;
    phnumTextField.layer.cornerRadius=6.f;
    
    UIImageView *phonenumberLeftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"phone.png"]];
    [phonenumberLeftView setFrame:CGRectMake(6, 6, 24, 24)];
    [phnumTextField setLeftViewMode:UITextFieldViewModeAlways];
    [phnumTextField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)]];
    [phnumTextField addSubview:phonenumberLeftView];
    
    [phnumTextField setClearsOnBeginEditing:YES];
    [phnumTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:phnumTextField];
    //验证码
    
    identCodeTextField =[[UITextField alloc]initWithFrame:CGRectMake(6.f, 112.f,SCREEN_WIDTH-122.f, 36.f)];
    identCodeTextField.delegate=self;
    identCodeTextField.backgroundColor=[UIColor whiteColor];
    identCodeTextField.layer.borderColor=[UIColor grayColor].CGColor;
    identCodeTextField.layer.borderWidth=0.3f;
    identCodeTextField.layer.cornerRadius=6.f;
    identCodeTextField.keyboardType=UIKeyboardTypeDecimalPad;
    identCodeTextField.returnKeyType=UIReturnKeyDone;
    identCodeTextField.placeholder=@"短信验证码";
    
    UIImageView *identCodeLeftView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"identifyCodeImage.png"]];
    [identCodeLeftView setFrame:CGRectMake(6, 6, 24, 24)];
    [identCodeTextField setLeftViewMode:UITextFieldViewModeAlways];
    [identCodeTextField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)]];
    [identCodeTextField addSubview:identCodeLeftView];
    
    [identCodeTextField setClearsOnBeginEditing:YES];
    [identCodeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:identCodeTextField];
    //邮箱
    emailTextFiled = [[UITextField alloc]initWithFrame:CGRectMake(6.f,152.f,SCREEN_WIDTH-12.f, 36.f)];
    emailTextFiled.delegate=self;
    emailTextFiled.backgroundColor=[UIColor whiteColor];
    emailTextFiled.layer.borderWidth=0.3f;
    emailTextFiled.layer.borderColor=[UIColor grayColor].CGColor;
    emailTextFiled.layer.cornerRadius=6.f;
    
    emailTextFiled.returnKeyType=UIReturnKeyDone;
    emailTextFiled.placeholder=@"邮箱（可以为空）";
    UIImageView *emailLeftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mail.png"]];
    [emailLeftView setFrame:CGRectMake(6, 6, 24, 24)];
    [emailTextFiled setLeftViewMode:UITextFieldViewModeAlways];
    [emailTextFiled setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)]];
    [emailTextFiled addSubview:emailLeftView];
    
    [emailTextFiled setClearsOnBeginEditing:YES];
    [emailTextFiled setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:emailTextFiled];
    //密码
    
    pswdTextField = [[UITextField alloc]initWithFrame:CGRectMake(6.f, 194, SCREEN_WIDTH-12, 36.f)];
    pswdTextField.delegate=self;
    pswdTextField.backgroundColor=[UIColor whiteColor];
    pswdTextField.layer.borderColor=[UIColor grayColor].CGColor;
    pswdTextField.layer.borderWidth=0.3f;
    pswdTextField.layer.cornerRadius=6.f;
    pswdTextField.returnKeyType=UIReturnKeyDone;
    pswdTextField.secureTextEntry = YES;
    pswdTextField.placeholder=@"密码";
    
    UIImageView *passwordLeftView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"password.png"]];
    [passwordLeftView setFrame:CGRectMake(6, 6, 24, 24)];
    [pswdTextField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)]];
    [pswdTextField setLeftViewMode:UITextFieldViewModeAlways];
    [pswdTextField addSubview:passwordLeftView];
    
    [pswdTextField setClearsOnBeginEditing:YES];
    [pswdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:pswdTextField];
}

- (void)showDelegate {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    delegateTextView.hidden = NO;
    
}

- (void)doubleTap {
    delegateTextView.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)nextStep
{
    int compareResult = 0;
    for (int i = 0; i<_areaArray.count; i++)
    {
        NSDictionary* dict1 = [_areaArray objectAtIndex:i];
        NSString* code1 = [dict1 valueForKey:@"zone"];
        if ([code1 isEqualToString:[@"+86" stringByReplacingOccurrencesOfString:@"+" withString:@""]])
        {
            compareResult = 1;
            NSString* rule1 = [dict1 valueForKey:@"rule"];
            NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
            BOOL isMatch = [pred evaluateWithObject:phnumTextField.text];
            if (!isMatch)
            {
                //手机号码不正确
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                                message:NSLocalizedString(@"errorphonenumber", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
    }
    
    if (!compareResult)
    {
        if (phnumTextField.text.length!=11)
        {
            //手机号码不正确
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                            message:NSLocalizedString(@"errorphonenumber", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    NSString* str = [NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),@"+86",phnumTextField.text];
    _str = [NSString stringWithFormat:@"%@",phnumTextField.text];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil)
                                                    message:str delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];
}

- (BOOL)checkCode{
    [self.view endEditing:YES];
    
    codeIsRight = NO;
    
    if(identCodeTextField.text.length != 4)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                        message:NSLocalizedString(@"verifycodeformaterror", nil)
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [SMSSDK commitVerificationCode:identCodeTextField.text phoneNumber:phnumTextField.text zone:@"86" result:^(NSError *error) {
            
            if (!error) {
                
                NSLog(@"验证成功");
                NSString* str = [NSString stringWithFormat:NSLocalizedString(@"verifycoderightmsg", nil)];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycoderighttitle", nil)
                                                                message:str
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
                
                codeIsRight = YES;
            }
            else
            {
                NSLog(@"验证失败");
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycodeerrortitle", nil)
                                                                message:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:@"commitVerificationCode"]]
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
                
            }
        }];
    }
    return codeIsRight;

}

- (void)userRegist{
    [self checkCode];
    
    if (codeIsRight) {
        NSLog(@"yes,right");
    }
    NSString *user_id = phnumTextField.text;
    NSString *passwd = pswdTextField.text;
    
    NSLog(@"user_id : %@  password: %@",user_id,passwd);
    
    if (!passwd) {
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSDictionary *parameters = @{@"user_id":user_id,@"passwd":passwd};
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/register";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"CHECKUSER SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt = [locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode = [dictCodes objectForKey:tt];
    
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    _defaultCode = defaultCode;
    _defaultCountryName = defaultCountryName;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        VerifyViewController* verify = [[VerifyViewController alloc] init];
        NSString* str2 = [@"+86" stringByReplacingOccurrencesOfString:@"+" withString:@""];
        [verify setPhone:phnumTextField.text AndAreaCode:str2];
        
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phnumTextField.text
                                       zone:str2
                           customIdentifier:nil
                                     result:^(NSError *error)
         {
             
             if (!error)
             {
                 NSLog(@"验证码发送成功");
//                 [self presentViewController:verify animated:YES completion:^{
//                     ;
//                 }];
             }
             else
             {
                 UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesenderrtitle", nil)
                                                                 message:[NSString stringWithFormat:@"错误描述：%@",[error.userInfo objectForKey:@"getVerificationCode"]]
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                       otherButtonTitles:nil, nil];
                 [alert show];
             }
             
         }];
        
    }
}




@end
