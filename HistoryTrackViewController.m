//
//  HistoryTrackViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/7/6.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "HistoryTrackViewController.h"
#import "Mymapview.h"
#import "Networking.h"
#import "IQActionSheetPickerView.h"
#import "Networking.h"

#import "PRNAmrRecorder.h"
#import "PRNAmrPlayer.h"

#define PATH_OF_DOCUMENT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface HistoryTrackViewController()<UITableViewDataSource,UITableViewDelegate,IQActionSheetPickerViewDelegate,PRNAmrRecorderDelegate>
{
    UIButton *firstButton;
    UIButton *secondButton;
    UIButton *thirdButton;
    UIButton *fouthButton;
    UIButton *selectedButton;
    
    UIButton *searchButton;
    
    UILabel *overLabel;
    
    UIView *backView;
    UITableView *listView;
    UITableView *chatView;
    NSMutableArray *typeArray;
    NSMutableArray *contentArray;
    NSMutableArray *timeArray;
    
    NSString *pointContent;
    NSString *showPoint;
    
    int scanCount;
    NSScanner *_scanner;
    NSTimer *_scanTimer;
    CLLocationCoordinate2D coordinates[2];
    CLLocationCoordinate2D lastCoordinate;
    MAPointAnnotation *lastAnnotation;
    MAPointAnnotation *touchAnnotation;
    
    IQActionSheetPickerView *picker;
    
    NSMutableArray *urls;
    NSMutableArray *sendTime;
    NSMutableArray *fromTypes;
    NSMutableArray *isHeards;
    UIView *cellBgView;
    
    PRNAmrRecorder *recorder;
    PRNAmrPlayer *player;
    BOOL outputMode;
    
    NSString *shouhuan_id;
    NSString *user_id;

}
@end
@implementation HistoryTrackViewController
@synthesize mapView,fenceChoice,dateButton;

- (void)viewDidLoad {
    i = 0;
    [super viewDidLoad];
    
    recorder = [[PRNAmrRecorder alloc] init];
    recorder.delegate = self;
    
    player = [[PRNAmrPlayer alloc] init];

    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    user_id = [[NSUserDefaults standardUserDefaults ] objectForKey:@"user_id"];
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initMapview];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_scanTimer invalidate];
    [mapView setHidden:NO];
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
}
- (void)initUI {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initView];
    [self initDatePicker];
    [self initTableView];
    [self initButton];
    [self initNavigation];
}
- (void)initNavigation {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17]; 
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"历史管理";  //设置标
    self.navigationItem.titleView= titleLabel;
}
- (void)initDatePicker {
    picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Date Picker" delegate:self];
    [picker setTag:6];
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
}


- (void)initTableView {
    listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 150)];
    listView.dataSource = self;
    listView.delegate = self;
    listView.showsVerticalScrollIndicator = NO;
    listView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    [listView setHidden:NO];
    [backView addSubview:listView];
    
    sendTime = [NSMutableArray new];
    urls = [NSMutableArray new];
    fromTypes = [NSMutableArray new];
    isHeards = [NSMutableArray new];
    
    chatView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    chatView.backgroundColor = [UIColor whiteColor];
    chatView.showsVerticalScrollIndicator = NO;
    chatView.delegate = self;
    chatView.dataSource = self;
    chatView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 140);
    chatView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    [chatView setHidden:YES];
    [backView addSubview:chatView];
    
    typeArray = [NSMutableArray new];
    contentArray = [NSMutableArray new];
    timeArray = [NSMutableArray new];
}

- (void)initMapview{
    Mymapview *mymapView = [Mymapview sharedInstance];
    
    [mymapView setFrame:CGRectMake(10, 141, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 150)];
    
    mapView = mymapView.mapView;
    
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
    
    mapView.delegate = self;
    
    
    
    [self.view addSubview:mymapView];
    [self.view sendSubviewToBack:mymapView];

}

- (void)initView{
    [self.view setBackgroundColor:DEFAULT_BACKGOUNDCOLOR];
    
    backView = [[UIView alloc] initWithFrame:CGRectMake(10, 141, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 150)];
    [backView setBackgroundColor:[UIColor whiteColor]];
    [backView setHidden:YES];
    [self.view addSubview:backView];
    
}

- (void)initButton {
    dateButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 70,100, 35)];
    
    NSDate *senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    [dateButton setTitle:locationString forState:UIControlStateNormal];
    [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dateButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [dateButton.titleLabel setTextAlignment:NSTextAlignmentLeft];

    [dateButton addTarget:self action:@selector(pressedCalendar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dateButton];
    
    CGFloat basicX = 10;
    CGFloat basicMove = (SCREEN_WIDTH - 20) / 4;
    firstButton = [self buttonWithTitle:@"足迹" andPointX:basicX];
    
    secondButton = [self buttonWithTitle:@"语音" andPointX:basicX + basicMove];
    
    thirdButton = [self buttonWithTitle:@"消息" andPointX:basicX + basicMove * 2];
    
    fouthButton = [self buttonWithTitle:@"运动" andPointX:basicMove * 3 + basicX];
    
    searchButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 67, 90, 36)];
    [searchButton setBackgroundColor:DEFAULTCOLOR];
    [searchButton.titleLabel setTextColor:[UIColor whiteColor]];
    [searchButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    
    [searchButton.layer setCornerRadius:6.f];
    [searchButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [searchButton.layer setBorderWidth:0.3f];
    
    [searchButton addTarget:self action:@selector(clickSearchButtonDown) forControlEvents:UIControlEventTouchUpInside];
    [searchButton addTarget:self action:@selector(clickSearchButton) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:searchButton];
    
    //点击 覆盖
    overLabel = [[UILabel alloc] init];
    [overLabel setBackgroundColor:DEFAULTCOLOR];
    [overLabel setText:@"轨迹"];
    [overLabel setTextAlignment:NSTextAlignmentCenter];
    [overLabel setTextColor:[UIColor whiteColor]];
    [overLabel setFrame:CGRectMake(6, 106, (SCREEN_WIDTH - 20) / 4, 36)];
    selectedButton = firstButton;
    [self.view addSubview:overLabel];
}

- (UIButton *)buttonWithTitle:(NSString *)title andPointX:(CGFloat)pointX {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(pointX, 106,(SCREEN_WIDTH - 20)/4, 36)];
    [button setBackgroundColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:0.5]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setUserInteractionEnabled:NO];
    
    [self.view addSubview:button];
    
    return button;
    
}
//点击button 事件
- (void)pressedCalendar {
    [picker show];
}

- (void)clickSearchButton {
    NSLog(@"search");
    [searchButton setBackgroundColor:[UIColor whiteColor]];
    [searchButton setTitleColor:DEFAULTCOLOR forState:UIControlStateNormal];
    
    if (selectedButton == fouthButton) {
        [self getStepnum];
        [chatView setHidden:YES];
        [listView setHidden:NO];
    }
    if (selectedButton == thirdButton) {
        [self getAlarmMessage];
        [chatView setHidden:YES];
        [listView setHidden:NO];
    }
    if (selectedButton == firstButton) {
        [_scanTimer invalidate];
        [mapView removeOverlays:mapView.overlays];
        [mapView removeAnnotations:mapView.annotations];
        
        [self getTrackMessage];
        [chatView setHidden:YES];
        [listView setHidden:YES];
    }
    if (selectedButton == secondButton){
        [self getVoicMessage];
        [chatView setHidden:NO];
        [listView setHidden:YES];
    }
}

- (void)clickSearchButtonDown{
    [searchButton setBackgroundColor:DEFAULTCOLOR];
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)getStepnum{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSLog(@"%@",dateButton.titleLabel.text);
    
    if (!shouhuan_id) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 @"start_time":[NSString stringWithFormat:@"%@ 00:00:01",dateButton.titleLabel.text],
                                 @"end_time":[NSString stringWithFormat:@"%@ 23:59:59",dateButton.titleLabel.text]
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/getstepnum";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"getstepsnum success");
            NSString *tempData = [dict objectForKey:@"data"];
            
            if (tempData.length <= 2) {
                [self showAlertnoRecord];
                
                return ;
            }

            
            NSRange range = {1,tempData.length - 2};
            
            NSString *data = [tempData substringWithRange:range];
            
            NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            
            NSLog( @"dict : %@",jsonDict);
            
            NSString *tempTime = [jsonDict objectForKey:@"time"];
            
            NSRange _range = {0,10};
            
            NSString *time = [tempTime substringWithRange:_range];
            
            NSString *step_nums = [jsonDict objectForKey:@"step_num"];
            
            NSLog(@"time %@ stem_num %@",time,step_nums);
            
            timeArray = [NSMutableArray arrayWithObjects:time, nil];
            contentArray = [NSMutableArray arrayWithObjects:step_nums, nil];
            
            [listView reloadData];
            
            NSLog(@"%@",data);
            
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
        
    }];

}

- (void)getAlarmMessage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 @"start_time":[NSString stringWithFormat:@"%@ 00:00:01",dateButton.titleLabel.text],
                                 @"end_time":[NSString stringWithFormat:@"%@ 23:59:59",dateButton.titleLabel.text]
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/getcrossandsos";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"getAlarmMessage success");
            
            NSString *tempData = [dict objectForKey:@"data"];
            
            if (tempData.length <= 2) {
                [self showAlertnoRecord];
                
                return ;
            }
            
            NSRange range = {1,tempData.length - 2};
            
            NSString *data = [tempData substringWithRange:range];
            
            NSArray *fenceArray = [data componentsSeparatedByString:@"}"];
            NSLog(@"fenceArray : %@",fenceArray);
            for (int j = 0; j < fenceArray.count - 1; j ++) {
                NSString *firstFenceTemp = [fenceArray objectAtIndex:j];
                
                if (j > 0) {
                    NSRange _range = {1,firstFenceTemp.length - 1};
                    firstFenceTemp = [firstFenceTemp substringWithRange:_range];
                }
                
                NSString *fenceMessage = [NSString stringWithFormat:@"%@}",firstFenceTemp];
                
                
                NSData *jsonData = [fenceMessage dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
                NSLog( @"dict : %@",jsonDict);
                
                NSString *sign = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"sign"]];
                
                if([sign isEqualToString:@"2"]){
                    [contentArray addObject:@"低电报警"];
                }
                if ([sign isEqualToString:@"5"]) {
                    [contentArray addObject:@"SOS报警"];
                }
                if ([sign isEqualToString:@"3"]) {
                    [contentArray addObject:@"手环拆除报警"];
                }
                NSString *point = [jsonDict objectForKey:@"point"];
                
                NSString *time = [jsonDict objectForKey:@"time"];
                
                [timeArray addObject:time];
                
                [typeArray addObject:@"手环报警"];
                
                
                
                NSLog(@"point %@,sign %@,time %@",point,sign,time);
            }
            [listView reloadData];

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
        
    }];

}

- (void)getVoicMessage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 @"start_time":[NSString stringWithFormat:@"%@ 00:00:01",dateButton.titleLabel.text],
                                 @"end_time":[NSString stringWithFormat:@"%@ 23:59:59",dateButton.titleLabel.text]
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/gethistoryrecord";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            
            NSString *tempData = [dict objectForKey:@"data"];
            if (tempData.length <= 2) {
                return ;
            }
            
            NSRange range = {1,tempData.length - 2};
            
            NSString *data = [tempData substringWithRange:range];
            
            NSArray *fenceArray = [data componentsSeparatedByString:@"}"];
            for (int j = 0; j < fenceArray.count - 1; j ++) {
                NSString *firstFenceTemp = [fenceArray objectAtIndex:j];
                
                if (j > 0) {
                    NSRange _range = {1,firstFenceTemp.length - 1};
                    firstFenceTemp = [firstFenceTemp substringWithRange:_range];
                }
                
                NSString *fenceMessage = [NSString stringWithFormat:@"%@}",firstFenceTemp];
                
                
                NSData *jsonData = [fenceMessage dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
                
                NSString *url = [jsonDict objectForKey:@"url"];
                
                NSString *time = [jsonDict objectForKey:@"time"];
                
                NSString *isHeard = [jsonDict objectForKey:@"isHeard"];
                
                NSString *from_type = [jsonDict objectForKey:@"from_type"];
                
                NSLog(@"url : %@",url);
                [self getVoiceDetailMessageByfilename:url];
                [urls addObject:url];
                [sendTime addObject:time];
                [isHeards addObject:isHeard];
                [fromTypes addObject:from_type];
                
            }
            [chatView reloadData];
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
        
    }];
    
}
- (void)getVoiceDetailMessageByfilename:(NSString *)fileName{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
    
    
    
    NSDictionary *parameters = @{
                                 @"url":fileName,
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/recorddownload";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *amrdata = [operation responseData];
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
        [amrdata writeToFile:filePath atomically:YES];
        
        [[NSUserDefaults standardUserDefaults] setObject:amrdata forKey:@"amrtestdata"];
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"getVoicMessage success");
            
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
        NSLog(@"失败 ： %@",error);
    }];
    
}

- (void)getTrackMessage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 @"start_time":[NSString stringWithFormat:@"%@ 00:00:01",dateButton.titleLabel.text],
                                 @"end_time":[NSString stringWithFormat:@"%@ 23:59:59",dateButton.titleLabel.text]
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/historylocation";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS JSON: %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"getTrackMessage success");
            
            NSString *tempData = [dict objectForKey:@"data"];
            
            if (tempData.length <= 2) {
                [self showAlertnoRecord];
                
                return ;
            }
            
            NSRange range = {1,tempData.length - 2};
            
            NSString *data = [tempData substringWithRange:range];
            
            NSArray *fenceArray = [data componentsSeparatedByString:@"}"];
            NSLog(@"fenceArray : %@",fenceArray);
            pointContent = [NSString new];
            for (int j = 0; j < fenceArray.count - 1; j ++) {
                NSString *firstFenceTemp = [fenceArray objectAtIndex:j];
                
                if (j > 0) {
                    NSRange _range = {1,firstFenceTemp.length - 1};
                    firstFenceTemp = [firstFenceTemp substringWithRange:_range];
                }
                
                NSString *fenceMessage = [NSString stringWithFormat:@"%@}",firstFenceTemp];
                
                
                NSData *jsonData = [fenceMessage dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
                NSLog( @"dict : %@",jsonDict);
                
                NSString *point = [jsonDict objectForKey:@"point"];
                
                NSLog(@"point : %@",point);
                
                pointContent = [NSString stringWithFormat:@"%@,%@",pointContent,point];
                }
            
            NSLog(@"pointContent : %@",pointContent);
            [self getTrack];

            
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
        
    }];

}

//画annotation的回调函数
//画annotation的回调函数
- (MAAnnotationView *)mapView:(MAMapView *)_mapView viewForAnnotation:(id<MAAnnotation>)_annotation{
    if ([_annotation isKindOfClass:[MAPointAnnotation class]])
    {
        NSLog(@"point");
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:_annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.pinColor = MAPinAnnotationColorGreen;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = NO;
        if (_annotation == touchAnnotation) {
            annotationView.image = [UIImage imageNamed:@"animationView"];
        }else{
            annotationView.image = [UIImage imageNamed:@"trackPoint"];
        }
        
        
        [annotationView setClipsToBounds:YES];
        [annotationView setFrame:CGRectMake(0, 0, 10, 10)];
        
        return annotationView;
    }
    return nil;
}
- (MAOverlayView *)mapView:(MAMapView *)_mapView viewForOverlay:(id <MAOverlay>)overlay
{
    //画圆的回调函数
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
        
        circleView.lineWidth = 5.f;
        circleView.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
        circleView.fillColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.8];
        circleView.lineDash = YES;
        
        return circleView;
    }
    //画折线的回调函数
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 2.f;
        polylineView.strokeColor = [UIColor colorWithRed:3/255.0 green:169/255.0 blue:245/255.0 alpha:1];
        polylineView.fillColor = [UIColor colorWithRed:3/255.0 green:169/255.0 blue:245/255.0 alpha:1];
        polylineView.lineJoinType = kMALineJoinRound;//连接类型
        polylineView.lineCapType = kMALineCapRound;//端点类型
        return polylineView;
    }
    //多边形的回调函数
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
        
        polygonView.lineWidth = 5.f;
        polygonView.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
        polygonView.fillColor = [UIColor colorWithRed:0.77 green:0.88 blue:0.94 alpha:0.8];
        polygonView.lineJoinType = kMALineJoinMiter;//连接类型
        
        return polygonView;
    }
    
    
    return nil;
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    NSLog(@"picker.date : %@",date);
    NSDateFormatter  *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd";
    [dateButton setTitle:[formatter stringFromDate:date] forState:UIControlStateNormal];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch");
    UITouch *touch = [[event allTouches]anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(firstButton.frame, point)) {
        selectedButton = firstButton;
        overLabel.frame = firstButton.frame;
        overLabel.text = firstButton.titleLabel.text;
        [mapView setHidden:NO];
        [backView setHidden:YES];
        typeArray = [NSMutableArray new];
        contentArray = [NSMutableArray new];
        timeArray = [NSMutableArray new];
        
    }
    if (CGRectContainsPoint(secondButton.frame, point)) {
        selectedButton = secondButton;
        overLabel.frame = secondButton.frame;
        overLabel.text = secondButton.titleLabel.text;
        [mapView setHidden:YES];
        [backView setHidden:NO];
        typeArray = [NSMutableArray new];
        contentArray = [NSMutableArray new];
        timeArray = [NSMutableArray new];
        [listView reloadData];
        [chatView setHidden:NO];
        [listView setHidden:YES];
        
    }
    if (CGRectContainsPoint(thirdButton.frame, point)) {
        selectedButton = thirdButton;
        overLabel.frame = thirdButton.frame;
        overLabel.text = thirdButton.titleLabel.text;
        [mapView setHidden:YES];
        [backView setHidden:NO];
        typeArray = [NSMutableArray new];
        contentArray = [NSMutableArray new];
        timeArray = [NSMutableArray new];
        [listView reloadData];
        [listView setHidden:NO];
        [chatView setHidden:YES];

    }
    if (CGRectContainsPoint(fouthButton.frame, point)) {
        selectedButton = fouthButton;
        overLabel.frame = fouthButton.frame;
        overLabel.text = fouthButton.titleLabel.text;
        [mapView setHidden:YES];
        [backView setHidden:NO];
        typeArray = [NSMutableArray new];
        contentArray = [NSMutableArray new];
        timeArray = [NSMutableArray new];
        [listView reloadData];
        [listView setHidden:NO];
        [chatView setHidden:YES];
    }
}

//table回调函数
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == chatView) {
        return 65;
    }
    
    return 45;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == chatView) {
        return urls.count;
    }
    
    return timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
    }
    if (tableView == chatView) {
        for (UIView *view in cell.subviews) {
            [view removeFromSuperview];
        }
        
        NSLog(@"chatviewcell : %@",indexPath);
        cellBgView = [[UIView alloc] initWithFrame:CGRectMake(6, 7, SCREEN_WIDTH - 32, 36)];
        //头像
        UIImageView *portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 30, 30)];
        [portraitView.layer setCornerRadius:15.f];
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@.protrait",shouhuan_id]];
        
        if (imageData) {
            UIImage *portraitImage = [UIImage imageWithData:imageData];
            [portraitView setImage:portraitImage];
        }
        [portraitView.layer setCornerRadius:6.f];
        [portraitView setClipsToBounds:YES];
        
        [cellBgView addSubview:portraitView];
        //消息体
        UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(36, 5, 150, 36) ];
        [playButton setTag:[indexPath row]];
        [playButton setBackgroundImage:[UIImage imageNamed:@"chatCell"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
        [playButton setClipsToBounds:YES];
        [playButton setTag:[indexPath row]];
        //静态时图标
        UIImageView *readStatus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"readStatus"]];
        readStatus.frame = CGRectMake(35, 8, 10, 20);
        [playButton addSubview:readStatus];
        
        [cellBgView addSubview:playButton];
        
        UILabel *sendTimelabel = [UILabel new];
        
        
        sendTimelabel.text = [sendTime objectAtIndex:(sendTime.count - 1 - [indexPath row])];
        sendTimelabel.textAlignment = NSTextAlignmentCenter;
        sendTimelabel.font = [UIFont systemFontOfSize:10];
        sendTimelabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - 20, 10);
        
        [cell addSubview:sendTimelabel];
        [cell addSubview:cellBgView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSLog(@"%ld",(long)[indexPath row]);
        
        return cell;

    }
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }

    //类型标签
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH / 2, 45)];
    if (selectedButton == fouthButton) {
        [typeLabel setText:@"当日计步数"];
    }else {
        [typeLabel setText:[typeArray objectAtIndex:[indexPath row]]];
    }
    [typeLabel setTextAlignment:NSTextAlignmentLeft];
    [typeLabel setTextColor:[UIColor blackColor]];
    [typeLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:typeLabel];
    
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];

    //时间标签
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, SCREEN_WIDTH - 20, 10)];
    
    NSString *time = [timeArray objectAtIndex:[indexPath row]];
    
    [timeLabel setText:time];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    [timeLabel setTextColor:[UIColor blackColor]];
    [timeLabel setFont:[UIFont systemFontOfSize:12]];
    
    [cell addSubview:timeLabel];
    
    NSLog(@"timeLabel");
    
    //    内容标签
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 + 20, 0, SCREEN_WIDTH/2 - 10, 45)];
    
    NSString *content = [NSString stringWithFormat:@"%@",[contentArray objectAtIndex:[indexPath row]]];
    
    [contentLabel setText:content];
    [contentLabel setTextColor:[UIColor blackColor]];
    [contentLabel setTextAlignment:NSTextAlignmentLeft];
    [contentLabel setFont:[UIFont systemFontOfSize:14]];
    
    [cell addSubview:contentLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)playRecord:(UIButton *)sender {
    NSString *recordFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:[urls objectAtIndex:(urls.count - 1 - sender.tag)]];
    
    NSLog(@"%@",[urls objectAtIndex:urls.count - 1 - sender.tag]);
    
    [player setSpeakMode:outputMode];
    [player playWithURL:[NSURL URLWithString:recordFile]];
}

- (void)getTrack{
    double pointX;
    double pointY = 0.0;
    NSScanner *scanner = [NSScanner scannerWithString:pointContent];
    
    do{
        [scanner scanDouble:&pointX];
        
        if (scanner.scanLocation < pointContent.length) {
            scanner.scanLocation ++;
        }
        
        if (![scanner isAtEnd]) {
            [scanner scanDouble:&pointY];
            scanner.scanLocation ++;
        }
        if (pointY && pointX) {
            showPoint = [NSString stringWithFormat:@"%@,%f,%f",showPoint,pointX,pointY];
        }
    }while (![scanner isAtEnd]);
    _scanner = [NSScanner scannerWithString:showPoint];

    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(showTrackByPoints) userInfo:nil repeats:YES];
}

- (void)showTrackByPoints{
    double pointX;
    double pointY;
    if (!_scanner) {
        _scanner = [NSScanner scannerWithString:showPoint];
    }
    if (_scanner.scanLocation < showPoint.length - 20 ) {

        [_scanner scanDouble:&pointX];
        
        if (_scanner.scanLocation < pointContent.length - 20) {
            _scanner.scanLocation ++;
        }
        
        [_scanner scanDouble:&pointY];
        
        if (_scanner.scanLocation < showPoint.length - 20) {
            _scanner.scanLocation ++;

        }
        CLLocationCoordinate2D location= CLLocationCoordinate2DMake(pointY, pointX);
        
        lastAnnotation = [MAPointAnnotation new];
        lastAnnotation.coordinate = location;
        [mapView addAnnotation:lastAnnotation];
        
        if (touchAnnotation) {
            [mapView removeAnnotation:touchAnnotation];
        }
        
        touchAnnotation = [MAPointAnnotation new];
        touchAnnotation.coordinate = location;
        
        
        [mapView setCenterCoordinate:location];
        [mapView addAnnotation:touchAnnotation];
        
        
        
        
        if (lastCoordinate.latitude) {
            coordinates[0] = location;
            coordinates[1] = lastCoordinate;
            
            MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:2];
            [mapView addOverlay:polyline];
        }
        
        lastCoordinate = location;
    }else{
        [_scanTimer invalidate];
    }

}

- (void)showAlertnoRecord{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"没有消息记录" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
