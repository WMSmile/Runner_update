//
//  PhoneSettingViewController.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/5.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "PhoneSettingViewController.h"
#import "Constant.h"
#import "PhoneCanMakeList.h"
#import "PhoneListView.h"
#import "SosphoneSetting.h"
#import "Networking.h"
@interface PhoneSettingViewController()
{
    UIButton *settingOne;
    UIButton *settingTwo;
    UIButton *settingThree;

    NSString *user_id;
    NSString *shouhuan_id;

    NSString *centerNumber;
    
    NSArray *sosArray;
    
    NSArray *whitelist1;
    NSArray *whitelist2;
    
    NSMutableArray *phb;
}

@end

@implementation PhoneSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];
    
    [self getPhoneData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)initData{
    phb = [NSMutableArray new];
}

- (void) initUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat basicY = 70;
    CGFloat basicMove = 54;
    
    settingOne = [self buttonWithImageName:@"setting_phone1"andPointY:basicY];
    
    settingTwo = [self buttonWithImageName:@"setting_phone2" andPointY:basicY + basicMove];
    
    settingThree = [self buttonWithImageName:@"setting_phone3" andPointY:basicMove * 2 + basicY];

}

- (UIButton *)buttonWithImageName:(NSString *)name andPointY:(CGFloat)pointY{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6, pointY, SCREEN_WIDTH - 12, 50)];
    [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_press",name]] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(showdetailPhoneSettingView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    return button;
}

- (void)getPhoneData{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    
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
            
            centerNumber = [jsonDict objectForKey:@"centernumber"];
            
            NSString *sosStr = [jsonDict objectForKey:@"sos"];
            
            sosArray = [sosStr componentsSeparatedByString:@","];
            
            NSString *whiteStr1 = [jsonDict objectForKey:@"whitelist1"];
    
            whitelist1 = [whiteStr1 componentsSeparatedByString:@","];
            
            NSString *whiteStr2 = [jsonDict objectForKey:@"whitelist2"];
            
            whitelist2 = [whiteStr2 componentsSeparatedByString:@","];
            
            NSLog(@"whitelist1 %@,whitelist2 %@",whitelist1,whitelist2);
            
            NSString *phb1 = [jsonDict objectForKey:@"phb"];
            
            NSString *phb2 = [jsonDict objectForKey:@"phb1"];
            
            NSArray *phbArray1 = [phb1 componentsSeparatedByString:@","];
            
            NSArray *phbArray2 = [phb2 componentsSeparatedByString:@","];
            
            if (phbArray1) {
                phb = [NSMutableArray arrayWithArray:phbArray1];
            } else{
                phb = [NSMutableArray new];
            }
            
            if (phbArray2) {
                for (int i = 0; i < phbArray2.count; i ++) {
                    [phb addObject:[phbArray2 objectAtIndex:i]];
                }
            }
            
            NSLog(@"phb : %@",phb);
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

- (void)showdetailPhoneSettingView:(UIButton *)button {
    if (button == settingThree) {
        PhoneListView *phoneList = [PhoneListView new];
        [phoneList setHidesBottomBarWhenPushed:YES];
        phoneList.phbArray = phb;
        [self.navigationController pushViewController:phoneList animated:YES];
    }
    if (button == settingTwo) {
        PhoneCanMakeList *phoneCanMake = [PhoneCanMakeList new];
        phoneCanMake.whitelist_1 = whitelist1;
        phoneCanMake.whitelist_2 = whitelist2;
        [phoneCanMake setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:phoneCanMake animated:YES];
    }
    if (button == settingOne) {
        SosphoneSetting *sosphone = [SosphoneSetting new];
        sosphone.centerNumber = centerNumber;
        sosphone.sosArray = sosArray;
        [sosphone setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:sosphone animated:YES];

    }
}
@end
