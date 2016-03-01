//
//  technicalSupportViewController.m
//  Runner
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "TechnicalSupportViewController.h"
#import "Constant.h"
#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
@interface TechnicalSupportViewController()
@end

@implementation TechnicalSupportViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initNavigation];
    [self initImage];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self setHidesBottomBarWhenPushed:NO];
    [super viewWillDisappear:animated];
}
-(void)initNavigation{
    [self.navigationController.navigationBar setBarTintColor:DEFAULTCOLOR];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:17];  //设置文本字体与大小
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"技术支持";  //设置标
    self.navigationItem.titleView= titleLabel;
}
-(void)initImage{
    UIImageView *supportImage =[[UIImageView alloc]initWithFrame:CGRectMake(0, 44.f,screen_width , screen_height-44)];
    supportImage.image=[UIImage imageNamed:@"logo_bg"];
    [self.view addSubview:supportImage];
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
