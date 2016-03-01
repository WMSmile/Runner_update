//
//  ChangePasswordViewController.h
//  爱之心
//
//  Created by 于恩聪 on 15/9/3.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPasswordViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) UITextField *passwordTextField;
@property (strong,nonatomic) UITextField *passwordAgainTextField;

@property (strong,nonatomic) UIButton *sureButton;

@end
