//
//  LoginViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/8/13.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "LoginViewController.h"
#import "Constant.h"
#import "AFNetworking.h"
#import "HomeViewController.h"
#import "RegViewController.h"
#import "Config.h"
#import "RegisterViewcontroller.h"
@interface LoginViewController ()
{
    CGFloat basicY;
    CGFloat basicMove;
    CGFloat leftSpace;
    
    NSString *shouhuan_id;
    NSString *shouhuan_name;
    NSString *user_id;
    NSString *password;
    
    NSMutableArray *shouhuan_message;
    
    UIButton *loginButton;
    
}

@end

@implementation LoginViewController
@synthesize passwordTextField,usernameTextField;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    shouhuan_message = [NSMutableArray new];
    
    [self initData];
    
    [self initUI];

}

- (void)initData{
    basicY = SCREEN_HEIGHT / 3 + 60;
    basicMove = 43;
    leftSpace = 20;
    
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];

    password = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_password"];

}

- (void)initUI{
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    [self initLogo];
    [self initTextField];
    [self initLoginButton];
    [self initPageFooter];

}
- (void)initLogo {
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - SCREEN_HEIGHT / 3 ) / 2, 60, SCREEN_HEIGHT / 3, SCREEN_HEIGHT / 3)];
    UIImage *logoImage=[UIImage imageNamed:@"login_logo"];
    logoView.layer.contents=(id)logoImage.CGImage;
    [self.view addSubview:logoView];
}
- (void)initTextField {
    usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftSpace,basicY, SCREEN_WIDTH - leftSpace * 2, 40.f)];
    usernameTextField.delegate = self;
    usernameTextField.backgroundColor = [UIColor whiteColor];
    usernameTextField.keyboardType = UIKeyboardTypeNumberPad;
    usernameTextField.returnKeyType =UIReturnKeyDone;
    usernameTextField.placeholder=@"用户名";
    usernameTextField.layer.borderColor=[UIColor grayColor].CGColor;
    usernameTextField.layer.borderWidth=0.3f;
    usernameTextField.layer.cornerRadius=6.f;
    if (user_id) {
        [usernameTextField setText:user_id];
    }
    
    UIImageView *usernameLeftView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"username"]];
    [usernameLeftView setFrame:CGRectMake(8, 8 , 24, 24)];
    [usernameTextField setLeftViewMode:UITextFieldViewModeAlways];
    [usernameTextField setLeftView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)]];
    [usernameTextField addSubview:usernameLeftView];
    
    [usernameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [usernameTextField setClearsOnBeginEditing:YES];
    [self.view addSubview:self.usernameTextField];
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(leftSpace, basicY + basicMove, SCREEN_WIDTH - leftSpace * 2, 40.f)];
    passwordTextField.delegate = self;
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.secureTextEntry = YES;
    passwordTextField.placeholder=@"密码";
    [passwordTextField setSecureTextEntry:YES];
    
    UIImageView *passwordWordLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginPassword.png"]];
    [passwordWordLeftView setFrame:CGRectMake(8, 8, 24 , 24)];
    [passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)];
    [passwordTextField setLeftView:leftView];
    
    [self.passwordTextField addSubview:passwordWordLeftView];
    [self.passwordTextField bringSubviewToFront:self.passwordTextField];
    
    [passwordTextField.layer setCornerRadius:6.f];
    [passwordTextField.layer setBorderColor:[UIColor grayColor].CGColor];
    [passwordTextField.layer setBorderWidth:0.3f];
    
    
    [passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [passwordTextField setClearsOnBeginEditing:YES];
    
    if (password) {
        [passwordTextField setText:password];
    }
    
    [self.view addSubview:self.passwordTextField];
    
}
- (void)initLoginButton {
    loginButton = [[UIButton alloc] initWithFrame:CGRectMake(20, basicY + basicMove * 2, SCREEN_WIDTH - 40, 36  )];
    loginButton.layer.cornerRadius=6.f;
    loginButton.layer.borderWidth =0.3;
    loginButton.layer.borderColor = [UIColor grayColor].CGColor;
    [loginButton setTitle:@"立即登陆" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
    [loginButton setBackgroundColor:DEFAULTCOLOR];
    
    
    [loginButton addTarget:self action:@selector(userLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [loginButton addTarget:self action:@selector(loginTouchdown) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:loginButton];
}

- (void)loginTouchdown{
    [loginButton setBackgroundColor:[UIColor whiteColor]];
}
- (void)initPageFooter {
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(6.f, SCREEN_HEIGHT - 50, SCREEN_WIDTH/2 - 6, 45  )];
    [registerButton setTitle:@"注册账号  " forState:UIControlStateNormal];
    [registerButton setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAccount) forControlEvents:UIControlEventTouchUpInside];
    
    [registerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [registerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [registerButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    
    [self.view addSubview:registerButton];
    
    UIButton *forgetPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2,SCREEN_HEIGHT - 50, SCREEN_WIDTH/2 - 6.f, 45  )];
    [forgetPasswordButton setTitle:@"|  忘记密码" forState:UIControlStateNormal];
    [forgetPasswordButton setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
    [forgetPasswordButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    
    [forgetPasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [forgetPasswordButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [forgetPasswordButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:forgetPasswordButton];
    
}
- (void)userLogin {
    //按钮状态转换
    [loginButton setBackgroundColor:DEFAULTCOLOR];

    NSString *newUserid = self.usernameTextField.text;
    NSString *newPassword = self.passwordTextField.text;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer=[AFHTTPRequestSerializer serializer];

    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    
    
    NSDictionary *parameters = @{
                                    @"user_id":newUserid,
                                    @"passwd":newPassword
                                    };

    NSString *url=@"http://101.201.211.114:8080/APIPlatform/login";

    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            
            NSString *watchMessage = [dict objectForKey:@"data"];
            
            NSLog(@"watchMessage : %@",watchMessage);
                        
            if (watchMessage) {
                NSString *tempData = [dict objectForKey:@"data"];
                
                NSRange range = {1,tempData.length - 2};
                
                NSString *data = [tempData substringWithRange:range];
                
                NSArray *fenceArray = [data componentsSeparatedByString:@"}"];
                NSLog(@"fenceArray : %@",fenceArray);
                for (int j = 0; j < fenceArray.count - 1; j ++) {
                    NSString *firstFenceTemp = [fenceArray objectAtIndex:j];
                    
                    if (j > 0) {
                        NSRange _range = {1,firstFenceTemp.length - 1};
                        firstFenceTemp = [firstFenceTemp substringWithRange:_range];
                    }
                    
                    NSString *fenceMessage = [NSString stringWithFormat:@"%@}",firstFenceTemp];
                    
                    
                    NSData *jsonData = [fenceMessage dataUsingEncoding:NSUTF8StringEncoding];
                    
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
                    NSLog( @"dict : %@",jsonDict);
                    
                    [shouhuan_message addObject:jsonDict];
                    
                }
                NSLog(@"shouhuan_message : %@",shouhuan_message);
                
                [[NSUserDefaults standardUserDefaults] setObject:shouhuan_message forKey:@"allshouhuanmessage"];
            }

            [[NSUserDefaults standardUserDefaults] setObject:passwordTextField.text forKey:@"user_password"];
            [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:@"user_id"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"shouhuan_id"] forKey:@"shouhuan_id"];
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"shouhuan_name"] forKey:@"shouhuan_name"];

            
            if (shouhuan_message.count == 0) {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                //由storyboard根据myView的storyBoardID来获取我们要切换的视图
                UIViewController *myView = [story instantiateViewControllerWithIdentifier:@"main"];
                
                //由navigationController推向我们要推向的view
                [self showViewController:myView sender:nil];
                
                return ;
            }

            NSDictionary *dict = [shouhuan_message objectAtIndex:0];
            
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"shouhuan_id"] forKey:@"shouhuan_id"];
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"name"] forKey:@"shouhuan_name"];
            
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            //由storyboard根据myView的storyBoardID来获取我们要切换的视图
            UIViewController *myView = [story instantiateViewControllerWithIdentifier:@"main"];
            
            //由navigationController推向我们要推向的view
            [self showViewController:myView sender:nil];
        }
        if ([code isEqualToString:@"200"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"用户名或密码错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if ([code isEqualToString:@"500"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"系统内部错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        NSLog(@"操作失败");
    }];

}
- (void)registerAccount {
    RegisterViewcontroller *registerViewcontroller = [RegisterViewcontroller new];
    registerViewcontroller.hidesBottomBarWhenPushed = YES;
    [self showViewController:registerViewcontroller sender:self];
}
- (void)findPassword {
    RegViewController *reg = [RegViewController new];
    reg.hidesBottomBarWhenPushed = YES;
    
    [self showViewController:reg sender:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
