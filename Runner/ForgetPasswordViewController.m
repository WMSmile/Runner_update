//
//  ChangePasswordViewController.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/3.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "LoginViewController.h"
#import "Constant.h"
#import "Networking.h"

@implementation ForgetPasswordViewController
@synthesize passwordAgainTextField,passwordTextField;
@synthesize sureButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void) initUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(6, 70,SCREEN_WIDTH - 12 , 36)];
    [self.passwordTextField setPlaceholder:@" 请输入密码"];
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 24, 24)];
    [leftView setImage:[UIImage imageNamed:@"loginPassword"]];
    [self.passwordTextField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)]];
    [self.passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordTextField addSubview:leftView];
    
    [self.passwordTextField.layer setCornerRadius:6.f];
    [self.passwordTextField.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.passwordTextField.layer setBorderWidth:0.3];
    
    [self.passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.passwordTextField setClearsOnBeginEditing:YES];
    
    [self.view addSubview:self.passwordTextField];
    
    self.passwordAgainTextField = [[UITextField alloc] initWithFrame:CGRectMake(6, 112, SCREEN_WIDTH - 12, 36)];
    [self.passwordAgainTextField setPlaceholder:@" 重新输入密码"];
    [self.passwordAgainTextField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)]];
    [self.passwordAgainTextField addSubview:leftView];
    
    [self.passwordAgainTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordAgainTextField.layer setCornerRadius:6.f];
    [self.passwordAgainTextField.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.passwordAgainTextField.layer setBorderWidth:0.3];
    
    [self.passwordAgainTextField setClearsOnBeginEditing:YES];
    [self.passwordAgainTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    [self.view addSubview:self.passwordAgainTextField];
    
    self.sureButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 154, SCREEN_WIDTH - 12, 36)];
    [self.sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.sureButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.sureButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
    
    [self.sureButton.layer setCornerRadius:6.f];
    [self.sureButton.layer setBorderWidth:0.3];
    [self.sureButton.layer setBorderColor:[UIColor grayColor].CGColor];
    
    [self.sureButton addTarget:self action:@selector(makeSure) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view  addSubview:self.sureButton];
}

- (void)makeSure {
    NSString *password = self.passwordTextField.text;
    NSString *passwordAgain = self.passwordAgainTextField.text;
    
    BOOL isRight = [self checkPassword:passwordAgain andPasswordAgain:password];
    
    if (isRight) {
        [[NSUserDefaults standardUserDefaults] setValue:passwordAgain forKey:@"password"];
        
        NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        NSLog(@"user_id:%@ password:%@",user_id,password);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        
        NSDictionary *parameters = @{@"user_id":user_id,@"new_password":password};
        
        NSString *url=@"http://101.201.211.114:8080/APIPlatform/getpassword";
        
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"SUCCESS JSON: %@", responseObject);
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            NSString *code = [dict objectForKey:@"code"];
            
            if ([code isEqualToString:@"100"]) {
                LoginViewController *login = [LoginViewController new];
                [self.navigationController popToViewController:login animated:YES];
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
            NSLog(@"Error: %@", error);
        }];
    }
    NSLog(@"password:%@ passwordAgain:%@",password,passwordAgain);
}

- (BOOL)checkPassword:(NSString *)password andPasswordAgain:(NSString *)passwordAgain {
    if (password.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码不能为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (password.length <= 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码长度不能低于6位" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (![password isEqualToString:passwordAgain]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码不一致" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

@end
