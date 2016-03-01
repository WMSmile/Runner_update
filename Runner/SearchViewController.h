//
//  ViewController.h
//  HelloAmap
//
//  Created by xiaoming han on 14-10-21.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PassTrendValueDelegate

- (void)passLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude;//1.1定义协议与方法
- (void)passTilte:(NSString *)title andSubTitle:(NSString *)subtitle;

@end

@interface SearchViewController : UIViewController<UITextFieldDelegate>

@property (retain,nonatomic) id <PassTrendValueDelegate> trendDelegate;

@end

