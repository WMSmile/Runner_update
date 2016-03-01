//
//  feedbackViewController.h
//  Runner
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController<UITextViewDelegate>

@property(nonatomic,strong)UIButton *softSelect;
@property(nonatomic,strong)UIButton *hadwareSelect;
@property(nonatomic,strong)UIButton *submit;

@property(nonatomic,strong)UITextView *contentTextView;
@property(nonatomic,strong)NSString *contents;

@end
