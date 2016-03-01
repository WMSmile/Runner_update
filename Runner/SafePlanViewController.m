//
//  safePlanViewController.m
//  Runner
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "SafePlanViewController.H"
#import "Constant.h"
@interface SafePlanViewController()

@end

@implementation SafePlanViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initNavigation];
    [self.navigationController setNavigationBarHidden:NO];

}
-(void)initNavigation{
    [self.navigationController.navigationBar setBarTintColor:DEFAULTCOLOR];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //自定义标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:17];  //设置文本字体与大小
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"平安计划";  //设置标
    self.navigationItem.titleView= titleLabel;
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
