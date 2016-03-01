//
//  userAgreementViewController.h
//  Runner
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAgreementViewController : UIViewController<UITextViewDelegate>

@property(nonatomic,strong)UIWebView *agreementWebView;

@property(nonatomic,strong)NSString *agreement;

@end
