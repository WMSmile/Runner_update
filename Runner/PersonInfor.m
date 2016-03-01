//
//  PersonInfor.m
//  Runner
//
//  Created by 于恩聪 on 15/7/10.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "PersonInfor.h"
#import "SYQRCodeViewController.h"
#import "IQActionSheetPickerView.h"
#import "Constant.h"
#import "Config.h"
#import "Networking.h"

@interface PersonInfor ()<IQActionSheetPickerViewDelegate>
{
    UIButton *portraitButton;
    UIButton *remarkButton;
    UIButton *codeButton;
    UIButton *birthdayButton;
    UIButton *sexButton;
    UIButton *removeButton;
    
    UILabel *remarkLabel;
    UILabel *birthdayLabel;
    UILabel *sexLabel;
    UILabel *channelLabel;
    UIImageView *portraitView;
    
    CGFloat basicMove;
    CGFloat basicY;
    NSTimer *timer;
    
    UIImagePickerController *imagePicker;
    
    UIAlertView *remarkAlert;
    //信息
    NSString *_birthday;
    NSString *_name;
    NSString *_sex;
    NSString *_channelid;
    NSString *sex;
    NSString *_clock;
    
    NSString *shouhuan_id;
    NSString *user_id;
    
    IQActionSheetPickerView *picker;

}

@end

@implementation PersonInfor

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
    
    NSLog(@"shouhuan_id : %@",shouhuan_id );
    
    NSLog(@"user_id :%@ shouhuan_id : %@",user_id,shouhuan_id);
    
    if (!user_id || !shouhuan_id) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/shouhuan";
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        NSString *data = [dict objectForKey:@"data"];
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        NSLog(@"data:%@",jsonDict);
        
        _birthday = [jsonDict objectForKey:@"birthday"];
        _name = [jsonDict objectForKey:@"name"];
        _sex = [jsonDict objectForKey:@"sex"];
        _channelid = [jsonDict objectForKey:@"shouhuan_id"];
        
                
        NSLog(@"sex:%@",_sex);
        
        int i = [_sex intValue];
        if (i == 0) {
            sex = @"女";
        }
        if (i == 1) {
            sex = @"男";
        }
        
        [remarkLabel setText:_name];
        [birthdayLabel setText:_birthday];
        [sexLabel setText:sex];
        [channelLabel setText:_channelid];
        
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
    self.view.backgroundColor = DEFAULT_BACKGOUNDCOLOR;
    
    basicMove = 55;
    basicY = 144;
    
    portraitButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 70, SCREEN_WIDTH - 12, 70)];
    
    [portraitButton setBackgroundColor:[UIColor whiteColor]];
    
    [portraitButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [portraitButton.layer setBorderWidth:0.3f];
    [portraitButton.layer setCornerRadius:6.f];
    
    [portraitButton setTitle:@"     头像" forState:UIControlStateNormal];
    [portraitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [portraitButton setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentLeft)];
    
    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.protrait",shouhuan_id]];

    portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 82, 10, 50, 50)];
    [portraitView.layer setCornerRadius:25.f];
    [portraitView.layer setBorderWidth:0.3f];
    [portraitView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        [portraitView setImage:image];
        [portraitView setClipsToBounds:YES];
    }
    
    [portraitButton addTarget:self action:@selector(getPortraitView) forControlEvents:UIControlEventTouchUpInside];
    
    [portraitButton addSubview:portraitView];
    [self.view addSubview:portraitButton];
    
    removeButton = [[UIButton alloc] initWithFrame:CGRectMake(6, basicY + basicMove * 5, SCREEN_WIDTH - 12, 50)];
    [removeButton setBackgroundColor:[UIColor whiteColor]];
    [removeButton setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
    [removeButton setTitle:@"解除绑定关系" forState:UIControlStateNormal];
    
    [removeButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [removeButton.layer setBorderWidth:0.3f];
    [removeButton.layer setCornerRadius:6.f];
    
    [removeButton addTarget:self action:@selector(removeWatch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:removeButton];
    
    remarkButton = [self buttonWithName:@"     昵称" andPointY:basicY];
    
    NSString *remarkMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_name"];
    if (remarkMessage) {
        [remarkLabel setText:remarkMessage];
    }

    
    codeButton = [self buttonWithName:@"    手表ID" andPointY:basicY + basicMove];
    
    birthdayButton = [self buttonWithName:@"    生日" andPointY:basicY + basicMove * 2];
    
    sexButton = [self buttonWithName:@"    性别" andPointY:basicY + basicMove * 3];
    
    //日期选择
    picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Date Picker" delegate:self];
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];

    
}

- (UIButton *)buttonWithName:(NSString *)name andPointY:(CGFloat)y {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(6, y, SCREEN_WIDTH - 12, 50)];
    [button setBackgroundColor:[UIColor whiteColor]];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:name forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentLeft)];
    
    [button.layer setBorderColor:[UIColor grayColor].CGColor];
    [button.layer setBorderWidth:0.3f];
    [button.layer setCornerRadius:6.f];
    
    [button setTag:(y - basicY) / basicMove];
    
    if (button.tag != 1) {
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 50)];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor grayColor]];
    [label setOpaque:YES];
    
    if (y == basicY) {
        remarkLabel = label;
        [button addSubview:remarkLabel];
    }
    if (y == basicY + basicMove) {
        channelLabel = label;
        [button addSubview:channelLabel];
    }
    
    if (y == basicY + basicMove * 2) {
        birthdayLabel = label;
        [birthdayLabel setText:@"生日"];
        [button addSubview:birthdayLabel];
    }
    
    if (y == basicY + basicMove * 3) {
        sexLabel = label;
        [sexLabel setText:@"性别"];
        [button addSubview:sexLabel];
    }
    [self.view addSubview:button];
    
    return button;
}
- (void)getPortraitView {
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        
    }
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

- (void)removeWatch{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    
    NSDictionary *parameters = @{
                                 @"user_id":user_id,
                                 @"shouhuan_id":shouhuan_id,
                                 @"delete_id":user_id
                                 };
    
    NSLog(@"parammeters : %@",parameters);
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/addrelation";
    
    [manager DELETE:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            
            NSLog(@"success");
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        if ([code isEqualToString:@"500"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"系统内部错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
//    NSLog(@"%@",info);
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [portraitView setImage:image];
    UIImage *addPic = image;
    
    CGSize imagesize = addPic.size;
    
    imagesize.height = 100;
    
    imagesize.width = 100;
    
    UIImage *imageNew = [self imageWithImage:addPic scaledToSize:imagesize];
    
    
    NSData *imageData = UIImageJPEGRepresentation(imageNew, 0.00001);
    //此处上传图片
    
    NSLog(@"开始上传图片");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    manager.requestSerializer=[AFJSONRequestSerializer serializer];

    NSDictionary *parameters = @{
                                 @"shouhuan_id":[NSString stringWithFormat:@"{\"shouhuan_id\":\"%@\"}",shouhuan_id]
                                 };
    
    
    [manager POST:@"http://101.201.211.114:8080/APIPlatform/shouhuan" parameters:parameters constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileData:imageData name:@"picture" fileName:@"portrait.jpg" mimeType:@"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"%@.protrait",shouhuan_id]];
}
//图片压缩
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}



- (void)clickButton:(UIButton *)sender {
    
    if (sender == birthdayButton) {
        [picker show];
        return;
    }
    if (sender == sexButton) {
        NSLog(@"change sex");
        if (!sexLabel.text) {
            [sexLabel setText:@"男"];
        }
        if (sexLabel.text) {
            if ([sexLabel.text isEqualToString:@"男"]) {
                [sexLabel setText:@"女"];
                NSLog(@"change to girl");
                [self changeValueName:@"sex" andValue:@"0"];
                return;
            }
            if ([sexLabel.text isEqualToString:@"女"]) {
                NSLog(@"change to boy");
                [sexLabel setText:@"男"];
                [self changeValueName:@"sex" andValue:@"1"];
            }
        }
    }
    
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",(long)alertView.tag);
    
    if (buttonIndex == 0) {
        return;
    }
    
    if (alertView.tag == 0) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *remark = textField.text;
        [remarkLabel setText:remark];
        
        NSLog(@"%@",remark);
        
        [[NSUserDefaults standardUserDefaults] setObject:remark forKey:@"user_name"];
        
        [self changeValueName:@"name" andValue:remark];
    }
}
//日期回调

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    NSLog(@"picker.date : %@",date);
    NSDateFormatter  *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd";
    [birthdayLabel setText:[formatter stringFromDate:date]];
    
    [self changeValueName:@"birthday" andValue:birthdayLabel.text];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}


-(void)changeValueName:(NSString *)name andValue:(NSString *)value{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSLog(@"%@ %@ %@ %@",value,name,user_id,shouhuan_id);
    
    NSDictionary *parameters = @{
                                 @"value":value,
                                 @"which":name,
                                 @"user_id":user_id,
                                 @"shouhuan_id":shouhuan_id
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/shouhuan";
    
    [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            
            NSLog(@"success");
            
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

@end
