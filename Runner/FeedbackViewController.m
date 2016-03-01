//
//  feedbackViewController.m
//  Runner
//
//  Created by Apple on 15/9/7.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Constant.h"
#import "Networking.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface FeedbackViewController()
{
    NSString *selected;
}

@end

@implementation FeedbackViewController

@synthesize submit,softSelect,hadwareSelect;
@synthesize contentTextView;
@synthesize contents;
-(void)viewDidLoad{
    [super viewDidLoad];
    
    selected = @"1";
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initNavigation];
    [self initField];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)initNavigation{
    [self.navigationController.navigationBar setBarTintColor:DEFAULTCOLOR];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"意见反馈";
    self.navigationItem.titleView= titleLabel;
}
-(void)initField{
    softSelect = [[UIButton alloc]initWithFrame:CGRectMake(6.f, 76.f,24.f , 24.f)];
    [self initButton:softSelect];
    [softSelect addTarget:self action:@selector(softSelectedTouch) forControlEvents:UIControlEventTouchUpInside];
    UILabel *softLabel = [[UILabel alloc]initWithFrame:CGRectMake(30.f, 70.f, screen_width/2-45.f, 36.f)];
    [self initLabel:softLabel withtitle:@"app软件(软件问题)"];
    
    
    hadwareSelect = [[UIButton alloc]initWithFrame:CGRectMake(screen_width/2.0+3, 76.f, 24.f, 24.f)];
    [self initButton:hadwareSelect];
    [hadwareSelect addTarget:self action:@selector(hardSelectedTouch) forControlEvents:UIControlEventTouchUpInside];
    UILabel *hardLabel = [[UILabel alloc]initWithFrame:CGRectMake(screen_width/2.0+27.f, 70.f, screen_width/2.0-45.f, 36.f)];
    [self initLabel:hardLabel withtitle:@"硬件(手表问题)"];
    [softSelect setBackgroundImage:[UIImage imageNamed:@"feedback_selected.png"] forState:UIControlStateNormal];
    [hadwareSelect setBackgroundImage:[UIImage imageNamed:@"feedback.png"] forState:UIControlStateNormal];

    
    contentTextView = [[UITextView alloc]initWithFrame:CGRectMake(6.f, 112.f, screen_width-12.f, screen_height/3.0)];
    contentTextView.delegate =self;
    contentTextView.layer.borderColor =[UIColor grayColor].CGColor;
    contentTextView.layer.borderWidth=0.3f;
    contentTextView.layer.cornerRadius = 6.f;
    contentTextView.font=[UIFont systemFontOfSize:17];
    [self.view addSubview:contentTextView];
    contentTextView.returnKeyType = UIReturnKeyDefault;
    contentTextView.keyboardType = UIKeyboardTypeDefault;
    contentTextView.selectedRange=NSMakeRange(0, 0);
    
    submit = [[UIButton alloc]initWithFrame:CGRectMake(6.f, screen_height/3.0+118.f, screen_width-12.f, 36.f)];
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    submit.layer.borderColor = [UIColor grayColor].CGColor;
    submit.layer.borderWidth=0.3f;
    submit.layer.cornerRadius = 6.f;
    [submit addTarget:self action:@selector(submitContents) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submit];
}
-(void)softSelectedTouch{
    NSLog(@"softSelected");
    [softSelect setBackgroundImage:[UIImage imageNamed:@"feedback_selected.png"] forState:UIControlStateNormal];
    [hadwareSelect setBackgroundImage:[UIImage imageNamed:@"feedback.png"] forState:UIControlStateNormal];
    selected = @"1";
}
-(void)hardSelectedTouch{
    NSLog(@"hardwareSelected");
    [softSelect setBackgroundImage:[UIImage imageNamed:@"feedback.png"] forState:UIControlStateNormal];
    [hadwareSelect setBackgroundImage:[UIImage imageNamed:@"feedback_selected.png"] forState:UIControlStateNormal];
    selected = @"2";
    
}
-(void)submitContents{
    NSLog(@"提交反馈意见");
    
    NSLog(@"%@",contentTextView.text);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/x-json"];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    NSDictionary *parameters = @{
                                 @"log_type":selected,
                                 @"user_id":user_id,
                                 @"event":contentTextView.text
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/userlog";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            
            NSLog(@"success");
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        if ([code isEqualToString:@"200"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"用户名或密码错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if ([code isEqualToString:@"500"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"系统内部错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}
-(void)initLabel:(UILabel *)label withtitle:(NSString *)title{
    [label setTextColor:[UIColor blackColor]];
    label.text=title;
    [label setFont:[UIFont systemFontOfSize:12]];
    label.backgroundColor=[UIColor clearColor];
    [self.view addSubview:label];
    return;
}
-(void)initButton:(UIButton *)button{
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderColor=[UIColor grayColor].CGColor;
    button.layer.borderWidth=0.3f;
    button.layer.cornerRadius =12.f;
    [self.view addSubview:button];
    return;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
//textview回调函数
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(textView == contentTextView)
    {
        contents = textView.text;
        NSLog(@"%@",contents);
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [contentTextView resignFirstResponder];
}
@end
