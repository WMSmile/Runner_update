//
//  ChangePassword.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "ChangePassword.h"
#import "Constant.h"
#import "Networking.h"
@interface ChangePassword()
{
    CGFloat basicY;
    CGFloat basicMove;
    
    UILabel *passwordLabel;
    UILabel *passwordAgainLabel;
    
    UITextField *oldTextField;
    UITextField *newTextField;
    UITextField *newAgainTextField;
    
    UIButton *sureButton;
    
    NSString *oldPassword;
    NSString *newPassword;
}
@end

@implementation ChangePassword
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    basicY = 70.f;
    
    basicMove = 40;
    
    oldTextField = [self textFieldWithPlaceholder:@"输入原秘密" andPointY:basicY];
    
    newTextField = [self textFieldWithPlaceholder:@"输入新密码" andPointY:basicY + basicMove];
    
    newAgainTextField = [self textFieldWithPlaceholder:@"重新输入新密码" andPointY:basicY + basicMove * 2];
    
    sureButton = [[UIButton alloc] initWithFrame:CGRectMake(6, basicMove * 3 + basicY, SCREEN_WIDTH - 12, 36)];
    [sureButton setBackgroundColor:[UIColor whiteColor]];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sureButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
    
    [sureButton.layer setCornerRadius:6.f];
    
    [sureButton addTarget:self action:@selector(makeSure) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sureButton];
}

- (UILabel *)labelWithTitle:(NSString *)title andPointY:(CGFloat)pointY {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, pointY, SCREEN_WIDTH - 12, 36)];
    [label setBackgroundColor:[UIColor whiteColor]];
    
    [label setText:title];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentLeft];
    
    [self.view addSubview:label];
    
    return label;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)text andPointY:(CGFloat)pointY {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(6.f, pointY, SCREEN_WIDTH - 12, 36)];
    [textField setBackgroundColor:[UIColor whiteColor]];
    
    [textField.layer setCornerRadius:6.f];
    
    [textField setPlaceholder:text];
    
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginPassword.png"]];
    [leftView setFrame:CGRectMake(6, 6, 24, 24)];
    [leftView setClipsToBounds:YES];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ICON_WIDTH, ICON_WIDTH)];
    [textField setLeftView:backView];
    [textField addSubview:leftView];
    
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setClearsOnBeginEditing:YES];
    
    [self.view addSubview:textField];
    
    return  textField;
}

- (void)makeSure {
    [self.view endEditing:YES];
    //获取 账号秘码
    NSString *tempPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_password"];
    
    if (![oldTextField.text isEqualToString:tempPassword]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"原来的密码 不正确" message:nil delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    oldPassword = oldTextField.text;
    
    if (![newTextField.text isEqualToString:newAgainTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"两次输入秘密不一致" message:nil delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSDictionary *parameters = @{
                                 @"user_id":user_id,
                                 @"new_password":newTextField.text
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/getpassword";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        if ([code isEqualToString:@"100"]) {
            [[NSUserDefaults standardUserDefaults] setObject:newTextField.text forKey:@"user_password"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"操作失败");
    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
