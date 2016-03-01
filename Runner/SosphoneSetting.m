//
//  SosphoneSetting.m
//  爱之心
//
//  Created by 于恩聪 on 15/9/9.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "SosphoneSetting.h"
#import "Constant.h"
#import "Config.h"
#import "SosphoneList.h"
#import "Command.h"
@interface SosphoneSetting()
{
    UITextField *textFields[4];
    NSArray *nameArray;
    NSArray *phoneArray;
    NSMutableArray *newPhoneArray;
    
    UIButton *sureButton;
    
    SosphoneList *sosPhonelist;
    
}
@end
@implementation SosphoneSetting
@synthesize centerNumber;
@synthesize sosArray;
- (void)viewDidLoad{
    [super viewDidLoad];
    [self initData];
    [self initUI];
}

- (void)initData {
    nameArray = [NSArray arrayWithObjects:@"1号键电话(SOS1)",@"2号键电话(SOS2)",@"3号键号码(SOS3)",@"监听号码设置", nil];
    
    newPhoneArray = [NSMutableArray new];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        
    NSLog(@"userid:%@",user_id);

}
- (void)initUI {
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    CGFloat basicY = 70;
    CGFloat basicMove = 40;
    for (int i = 0; i < 4; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, basicY + i * basicMove, SCREEN_WIDTH / 2 - 6, 36)];
        [label setText:[nameArray objectAtIndex:i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:DEFAULTCOLOR];
        
        [self.view addSubview:label];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, basicY + basicMove * i, SCREEN_WIDTH / 2 - 6, 36)];
        
        [textField.layer setCornerRadius:6.f];
        
        [textField setBackgroundColor:[UIColor whiteColor]];
        [textField setPlaceholder:@"  输入号码"];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        textFields[i] = textField;
        NSLog(@"before");
        if (sosArray.count > 0) {
            NSLog(@"after");
            if (i!=3 && sosArray.count > i && [sosArray objectAtIndex:i]) {
                [textField setText:[sosArray objectAtIndex:i]];
                
                NSLog(@"over");
            }
            if (centerNumber && i == 3) {
                [textField setText:self.centerNumber];
            }

        }        
        [self.view addSubview:textField];
    }
    
    sureButton = [[UIButton alloc] initWithFrame:CGRectMake(6, basicY + 5 * basicMove, SCREEN_WIDTH - 12, 36)];
    [sureButton setBackgroundColor:[UIColor whiteColor]];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureButton setTitleColor:DEFAULTCOLOR forState:UIControlStateHighlighted];
    [sureButton addTarget:self action:@selector(clickSureButton) forControlEvents:UIControlEventTouchUpInside];
    
    [sureButton.layer setCornerRadius:6.f];
    
    [self.view addSubview:sureButton];
}

- (void)clickSureButton {
    for (int i = 0; i < 4; i ++) {
        [newPhoneArray addObject:textFields[i].text];
        
        if (textFields[i].text.length > 0 && textFields[i].text.length!=11) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入号码不正确" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [textFields[i] becomeFirstResponder];
            newPhoneArray = [NSMutableArray new];
            return;
        }
        
        if ((i == 0 || i == 1 || i==3 ) && textFields[i].text.length <= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SOS1,SOS2,中心号码必须设置" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [textFields[i] becomeFirstResponder];
            newPhoneArray = [NSMutableArray new];
            return;

        }
    }
    if (textFields[0].text) {
        [Command commandWithName:@"SOS1" andParameter:textFields[0].text];
    }
    if (textFields[1].text) {
        [Command commandWithName:@"SOS2" andParameter:textFields[1].text];
    }
    if (textFields[2].text) {
        [Command commandWithName:@"SOS3" andParameter:textFields[2].text];
    }
    [Command commandWithName:@"SOS" andParameter:[NSString stringWithFormat:@"%@,%@,%@",textFields[0].text,textFields[1].text,textFields[2].text]];
    NSLog(@"newPhoneArray:%@",newPhoneArray);
    if (textFields[3].text) {
        [Command commandWithName:@"CENTER" andParameter:textFields[3].text];
    }
    sosPhonelist.phoneList = newPhoneArray;
    BOOL success = [Config saveSosphoneList:sosPhonelist];
    if (success) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
