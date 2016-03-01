//
//  RegViewController.m
//  SMS_SDKDemo
//
//  Created by 掌淘科技 on 14-6-4.
//  Copyright (c) 2014年 掌淘科技. All rights reserved.
//

#import "RegViewController.h"
#import "VerifyViewController.h"

#import "Constant.h"
#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/SMSSDK+ExtexdMethods.h>

@interface RegViewController ()
{
    SMSSDKCountryAndAreaCode* _data2;
    NSString* _str;
    NSMutableData* _data;
    int _state;
    NSString* _localPhoneNumber;
    
    NSString* _localZoneNumber;
    NSString* _appKey;
    NSString* _duid;
    NSString* _token;
    NSString* _appSecret;
    
    NSMutableArray* _areaArray;
    NSString* _defaultCode;
    NSString* _defaultCountryName;
}

@end

@implementation RegViewController

-(void)clickLeftButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        _window.hidden = YES;
    }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //不允许用户输入 国家码
    if (textField ==_areaCodeField)
    {
        [self.view endEditing:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    _data2 = data;
    NSLog(@"the area data：%@,%@", data.areaCode,data.countryName);
    
    self.areaCodeField.text = [NSString stringWithFormat:@"+%@",data.areaCode];
    [self.tableView reloadData];
}

-(void)nextStep
{
    int compareResult = 0;
    for (int i = 0; i<_areaArray.count; i++)
    {
        NSDictionary* dict1 = [_areaArray objectAtIndex:i];
        NSString* code1 = [dict1 valueForKey:@"zone"];
        
        if ([code1 isEqualToString:@"86"])
        {
            compareResult = 1;
            NSString* rule1 = [dict1 valueForKey:@"rule"];
            NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
            BOOL isMatch = [pred evaluateWithObject:self.telField.text];
            if (!isMatch)
            {
                //手机号码不正确
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"手机号码不正确"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
        }
    }
    
    if (!compareResult)
    {
        if (self.telField.text.length!=11)
        {
            //手机号码不正确
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"手机号码不正确"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    NSString* str = [NSString stringWithFormat:@"%@:%@ %@",@"发送验证码到",@"+86",self.telField.text];
    _str = [NSString stringWithFormat:@"%@",self.telField.text];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:str
                                                  message:nil
                                                   delegate:self
                                        cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定",nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        VerifyViewController* verify = [[VerifyViewController alloc] init];
        NSString* str2 = [@"+86" stringByReplacingOccurrencesOfString:@"+" withString:@""];
        [verify setPhone:self.telField.text AndAreaCode:str2];
        
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.telField.text
                                                                       zone:str2
                                                           customIdentifier:nil
                                                                     result:^(NSError *error)
        {
            
            if (!error)
            {
                NSLog(@"验证码发送成功");
                [self presentViewController:verify animated:YES completion:^{
                    ;
                }];
            }
            else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"错误描述：%@",[error.userInfo objectForKey:@"getVerificationCode"]]
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }];
        
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
    [self initNavigation];
    //
    CGFloat statusBarHeight=0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        statusBarHeight=20;
        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        [self.view addSubview:statusView];
        
        [statusView setBackgroundColor:DEFAULTCOLOR];
    }
    
    statusBarHeight = statusBarHeight - 45;
    
    //区域码
    UITextField* areaCodeField = [[UITextField alloc] init];
    areaCodeField.frame = CGRectMake(10, 155 + statusBarHeight, (self.view.frame.size.width - 30)/4, 40 + statusBarHeight/4);
    areaCodeField.borderStyle = UITextBorderStyleBezel;
    areaCodeField.text = [NSString stringWithFormat:@"+86"];
    areaCodeField.textAlignment = NSTextAlignmentCenter;
    areaCodeField.font = [UIFont fontWithName:@"Helvetica" size:18];
    areaCodeField.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:areaCodeField];
    
    //
    UITextField* telField = [[UITextField alloc] init];
    telField.frame = CGRectMake(20 + (self.view.frame.size.width - 30)/4, 155 + statusBarHeight,(self.view.frame.size.width - 30)*3/4 , 40 + statusBarHeight/4);
    telField.borderStyle = UITextBorderStyleBezel;
    telField.placeholder = NSLocalizedString(@"telfield", nil);
    telField.keyboardType = UIKeyboardTypeDefault;
    telField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:telField];
    
    //
    UIButton* nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    NSString *icon = [NSString stringWithFormat:@"smssdk.bundle/button4.png"];
    [nextBtn setBackgroundColor:DEFAULTCOLOR];

    nextBtn.frame = CGRectMake(10, 220 + statusBarHeight, self.view.frame.size.width - 20, 42);
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    _telField = telField;
    _areaCodeField = areaCodeField;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.areaCodeField.delegate = self;
    self.telField.delegate = self;
    
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
    _areaCodeField.text = [NSString stringWithFormat:@"+%@",defaultCode];
    
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    _defaultCode = defaultCode;
    _defaultCountryName = defaultCountryName;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] ;
        
    }
    cell.textLabel.text = NSLocalizedString(@"countrylable", nil);
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    if (_data2)
    {
        cell.detailTextLabel.text = _data2.countryName;
    }
    else
    {
        cell.detailTextLabel.text = _defaultCountryName;
    }
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *tempView = [[UIView alloc] init];
    [cell setBackgroundView:tempView];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}

@end
