//
//  ChatViewController.h
//  Runner
//
//  Created by 于恩聪 on 15/7/31.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordTool;
@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UIButton *recordButton;

@property (nonatomic,strong) UINavigationItem *navigationItem;
@property (nonatomic,strong) UIBarButtonItem *leftButton;
@property (nonatomic,strong) UIBarButtonItem *rightButton;
@property (nonatomic,strong) UIButton *titleButton;

//record
@property (nonatomic, strong) RecordTool *recordTool;
//table
@property (nonatomic,strong) UITableView *table;

//cell bg
@property (nonatomic,strong) UIView *cellBgView;
@property (nonatomic,strong) UIImageView *unreadTag;
@property (nonatomic,strong) UIImageView *readStatus;

@property (nonatomic,strong) UIImageView *filtrateView;
@property (nonatomic,strong) UIButton *button1;
@property (nonatomic,strong) UIButton *button2;
@property (nonatomic,strong) UIButton *button3;
@property (nonatomic,strong) UIButton *button4;
@property (nonatomic,strong) NSMutableArray *filtrateArray;




@end
