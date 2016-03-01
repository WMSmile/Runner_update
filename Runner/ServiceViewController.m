//
//  ServiceViewController.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/4.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "ServiceViewController.h"
#import "Constant.h"
#import "SafePlanViewController.h"
#import "TechnicalSupportViewController.h"
#import "UserAgreementViewController.h"
#import "OperationViewController.h"
#import "FeedbackViewController.h"

@interface ServiceViewController()
{
    UIButton *safePlanButton;
    UIButton *supportButton;
    UIButton *suggestButton;
    UIButton *delegateButton;
    UIButton *operationButton;
    
    NSTimer *timer;
}
@end


@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)initUI {
    [self initNavigation];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 20, SCREEN_WIDTH - 12, 148)];
    imageView.image = [UIImage imageNamed:@"service_image"];
    
    [self.view addSubview:imageView];
    
    CGFloat basicY = 170;
    CGFloat basicMove = 52;
    safePlanButton = [self buttonWithBackImageName:@"service_safe" andPointY:basicY];
    [safePlanButton addTarget:self action:@selector(showSafePlanView) forControlEvents:UIControlEventTouchUpInside];
    
    supportButton = [self buttonWithBackImageName:@"service_logo" andPointY:basicY + basicMove];
    [supportButton addTarget:self action:@selector(showSupportView) forControlEvents:UIControlEventTouchUpInside];
    
    suggestButton = [self buttonWithBackImageName:@"service_suggest" andPointY:basicY + basicMove * 2];
    [suggestButton addTarget:self action:@selector(showSuggestView) forControlEvents:UIControlEventTouchUpInside];
    
    delegateButton = [self buttonWithBackImageName:@"service_agreement" andPointY:basicY + basicMove * 3];
    [delegateButton addTarget:self action:@selector(showDelegateView) forControlEvents:UIControlEventTouchUpInside];
    
    operationButton = [self buttonWithBackImageName:@"service_help" andPointY:basicY + basicMove * 4];
    [operationButton addTarget:self action:@selector(showOperationView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initNavigation {
    [self.navigationController.navigationBar setBarTintColor:DEFAULTCOLOR];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"服务";
    self.navigationItem.titleView= titleLabel;
}

- (UIButton *)buttonWithBackImageName:(NSString *)imageName andPointY:(CGFloat)y {

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6, y, SCREEN_WIDTH - 12, 50)];
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [button.layer setBorderColor:[UIColor grayColor].CGColor];
    [button.layer setBorderWidth:0.23f];
    [button.layer setCornerRadius:5.f];
    
    NSString *buttonPress = [NSString stringWithFormat:@"%@_press",imageName];
    UIImage *buttonPressImage = [UIImage imageNamed:buttonPress];
    [button setBackgroundImage:buttonPressImage forState:UIControlStateHighlighted];

    
    [self.view addSubview:button];
    
    return button;
}

- (void)showSafePlanView {
    SafePlanViewController *safePlanView = [SafePlanViewController new];
    [safePlanView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:safePlanView animated:YES];
}

- (void)showSupportView {
    TechnicalSupportViewController *tech = [TechnicalSupportViewController new];
    [tech setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tech animated:YES];
}

- (void)showOperationView {
    OperationViewController *operation = [OperationViewController new];
    [operation setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:operation animated:YES];
}

- (void)showSuggestView {
    FeedbackViewController *feedbackView = [FeedbackViewController new];
    [feedbackView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:feedbackView animated:YES];
}

- (void)showDelegateView {
    UserAgreementViewController *delegateView = [UserAgreementViewController new];
    [delegateView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:delegateView animated:YES];
}
@end
