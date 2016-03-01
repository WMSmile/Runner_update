//
//  FirstViewController.h
//  Runner
//
//  Created by 于恩聪 on 15/6/23.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"

@interface HomeViewController : UIViewController<NSURLConnectionDataDelegate,NSURLConnectionDelegate,PassTrendValueDelegate>
@property (nonatomic,strong) UIButton *zoominButton;
@property (nonatomic,strong) UIButton *zoomoutButton;

@property (nonatomic,strong) UINavigationItem *navigationItem;
@property (nonatomic,strong) UIButton *titleButton;

@property (nonatomic,strong) NSMutableArray *tableArray;

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) NSString *currentLocation;

- (void)getWatchportrait;

@end

