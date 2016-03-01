//
//  LoginViewController.h
//  Runner
//
//  Created by 于恩聪 on 15/8/13.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PassValueDelegate

- (void)passUserLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude;//1.1定义协议与方法
- (void)passTilte:(NSString *)title andSubTitle:(NSString *)subtitle;

- (void)passBat:(NSString *)bat;
- (void)passOnline:(NSString *)online;


@end

@interface LoginViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) UITextField *passwordTextField;
@property (strong,nonatomic) UITextField *usernameTextField;

@property (retain,nonatomic) id <PassValueDelegate> trendDelegate;


@end
