//
//  userAgreementViewController.m
//  Runner
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "UserAgreementViewController.h"
#import "Constant.h"
@interface UserAgreementViewController()

@end

@implementation UserAgreementViewController
@synthesize agreement;
@synthesize agreementWebView;

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initNavigation];
    //[self initTextView];
    [self initWebView];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)initNavigation{
    
    //自定义标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:17];  //设置文本字体与大小
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"用户协议";  //设置标
    self.navigationItem.titleView= titleLabel;
}

-(void)initWebView{
    agreementWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    NSURL *fileUrl = [[NSBundle mainBundle]URLForResource:@"userAgreement.txt" withExtension:nil];
    
    NSData *textData = [NSData dataWithContentsOfURL:fileUrl options:NSDataReadingMappedAlways error:nil];
    [agreementWebView loadData:textData MIMEType:@"text/txt" textEncodingName:@"UTF-8" baseURL:nil];
    [self.view addSubview:agreementWebView];
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
