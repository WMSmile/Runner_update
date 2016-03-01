//
//  RedFlowerViewController.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/4.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "RedFlowerViewController.h"
#import "Constant.h"
#import "Networking.h"
#import "Command.h"

@interface RedFlowerViewController()
{
    UILabel *countLabel;
    
    UIButton *addButton;
    
    UIButton *clearButton;
    
    NSString *flower_count;
    
    NSString *shouhuan_id;
    NSString *user_id;
    
}
@end

@implementation RedFlowerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
}
- (void)initData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    
    if (!user_id || !shouhuan_id) {
        return;
    }
    
    NSLog(@"user_id :%@ shouhuan_id : %@",user_id,shouhuan_id);
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/shouhuan";
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        NSString *data = [dict objectForKey:@"data"];
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        flower_count = [jsonDict objectForKey:@"flower"];
        
        if (flower_count.length > 0) {
            
            NSLog(@"%@",flower_count);
            [countLabel setText:[NSString stringWithFormat:@"当前红花的数量:%@",flower_count]];
        } else{
            [countLabel setText:@"当前红花的数量:0"];
            flower_count = @"0";
        }

        if ([code isEqualToString:@"100"]) {
            NSLog(@"success");
        }
        if ([code isEqualToString:@"200"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"200" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        if ([code isEqualToString:@"500"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"500" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"操作失败");

    }];
}

- (void)initUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 70, SCREEN_WIDTH - 12, 36)];
    
    [countLabel setTextAlignment:NSTextAlignmentCenter];
    [countLabel setTextColor:DEFAULTCOLOR];
    
    [countLabel.layer setBorderColor:[UIColor grayColor].CGColor];
    [countLabel.layer setBorderWidth:0.3f];
    [countLabel.layer setCornerRadius:6.f];
    
    [self.view addSubview:countLabel];
    
    addButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 112, SCREEN_WIDTH - 12, 36)];
    [addButton setTitle:@"奖励一朵小红花" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [addButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
    
    [addButton.layer setCornerRadius:6.f];
    [addButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [addButton.layer setBorderWidth:0.3f];
    
    [addButton addTarget:self action:@selector(addRedFlower) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addButton];
    
    clearButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 154, SCREEN_WIDTH - 12, 36)];
    [clearButton setTitle:@"清空小红花" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [clearButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
    
    [clearButton.layer setCornerRadius:6.f];
    [clearButton.layer setBorderWidth:0.3f];
    [clearButton.layer setBorderColor:[UIColor grayColor].CGColor];
    
    [clearButton addTarget:self action:@selector(clearRedFlowers) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:clearButton];
}

- (void)addRedFlower {
    int num = 0;
    if (flower_count) {
        num = [flower_count intValue];
        
        if (num == 9) {
            num = -1;
        }
    }
    num++;
    flower_count = [NSString stringWithFormat:@"%d",num];
    
    [countLabel setText:[NSString stringWithFormat:@"小红花的数量:%@",flower_count]];
    
    [self makeSureChange];

}

- (void)clearRedFlowers {
    flower_count = [NSString stringWithFormat:@"%d",0];
    
    [countLabel setText:[NSString stringWithFormat:@"小红花的数量:%d",0]];
    
    [self makeSureChange];

}

- (void)makeSureChange{
    NSLog(@"flower_count : %@",flower_count);
    
    [Command commandWithName:@"FLOWER" andParameter:flower_count];
}
@end
