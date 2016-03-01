//
//  operationViewController.m
//  Runner
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "OperationViewController.h"
@interface OperationViewController()

@end

@implementation OperationViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initNavigation];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)initNavigation{
    
    //自定义标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:17];  //设置文本字体与大小
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"操作说明";  //设置标
    self.navigationItem.titleView= titleLabel;
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
