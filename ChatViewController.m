//
//  ChatViewController.m
//  Runner
//
//  Created by 于恩聪 on 15/7/31.
//  Copyright (c) 2015年 于恩聪. All rights reserved.
//

#import "ChatViewController.h"
#import "Constant.h"
#import "Networking.h"

#import "PRNAmrRecorder.h"
#import "PRNAmrPlayer.h"


#define FILTRATE_WIDTH 100
#define FILTRATE_CELL_HEIGHT 36

#define PATH_OF_DOCUMENT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface ChatViewController()<PRNAmrRecorderDelegate,UIGestureRecognizerDelegate>
{
    UIImageView *unreadTags[10];
    
    PRNAmrRecorder *recorder;
    PRNAmrPlayer *player;
    BOOL outputMode;
    
    
    UIImageView *animationView;
    NSMutableArray *messageArrays;
    //存取singleArray{url,time,from_type}
    
    NSString *user_id;
    NSString *shouhuan_id;
    
    //压缩延时
    NSTimer *timer;
    NSTimer *updateTimer;
    
    NSString *online;
}
@end
@implementation ChatViewController
@synthesize recordButton;
@synthesize leftButton,titleButton,navigationItem;
@synthesize table;
@synthesize cellBgView;
@synthesize unreadTag;
@synthesize readStatus;
@synthesize filtrateView;
@synthesize filtrateArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    [self initrecordButton];
    
    [self initData];
    [self initTable];
    [self getVoicMessage];

}

- (void)viewWillAppear:(BOOL)animated {
    [self viewWillDisappear:animated];
    NSString *hasChangeValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasChangeWatch"];
    
    if ([hasChangeValue isEqualToString:@"1"]) {
        [self initData];
        [self initTable];
        [self getVoicMessage];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"hasChangeWatch"];
    }
    NSString *updateVoice = [[NSUserDefaults standardUserDefaults] objectForKey:@"updateVoice"];
    
    if ([updateVoice isEqualToString:@"1"]) {
        [self initData];
        [self initTable];
        [self getVoicMessage];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"updateVoice"];

    }
    
    online = [[NSUserDefaults standardUserDefaults] objectForKey:@"online"];
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getVoicMessage) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [player stop];
    
    [updateTimer invalidate];
}
- (void)initData{
    if (!recorder) {
        recorder = [[PRNAmrRecorder alloc] init];
        recorder.delegate = self;
        
        player = [[PRNAmrPlayer alloc] init];

    }
    shouhuan_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouhuan_id"];
    user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
}

- (void)initTable {
    messageArrays = [NSMutableArray new];
    
    if (!table) {
        table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        table.backgroundColor = [UIColor whiteColor];
        table.showsVerticalScrollIndicator = NO;
        table.delegate = self;
        table.dataSource = self;
        table.frame = CGRectMake(10, 50, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 104);
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        [self.view addSubview:table];
        [self.view sendSubviewToBack:table];

    }
}

- (void)initrecordButton {
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake(6, SCREEN_HEIGHT - 85, SCREEN_WIDTH - 12
        , 30)];
    [self.recordButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.recordButton setTitle:@"松开结束" forState:UIControlStateHighlighted];
    
    [self.recordButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"voiceBtn"] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"voiceBtnPress"] forState:UIControlStateHighlighted];
    
    [self.view addSubview:self.recordButton];
    
    [self.recordButton addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(beginRecord) forControlEvents:UIControlEventTouchDown];
}

- (void)initNavigation {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
    navigationItem = [[UINavigationItem alloc] initWithTitle:@"首页"];
    
    titleButton = [UIButton new];
    titleButton.backgroundColor = [UIColor clearColor];
    [titleButton setTitle:@"聊天" forState:UIControlStateNormal];
    [titleButton setTintColor:[UIColor whiteColor]];
    [titleButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    navigationItem.titleView = titleButton;
    
    leftButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:nil];
    [navigationItem setLeftBarButtonItem:leftButton];
    
    [self.navigationController.navigationBar pushNavigationItem:navigationItem animated:NO];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:252/255.0 green:92/255.0 blue:64/255.0 alpha:1]];
}

//点击事件
- (void)beginRecord{
    if ([online isEqualToString:@"0"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"手环不在线或未绑定手环" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSString *recordFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"test.amr"];
    
    [recorder setSpeakMode:NO];
    [recorder recordWithURL:[NSURL URLWithString:recordFile]];
}

- (void)stopRecord{
    if ([online isEqualToString:@"0"]) {
        return;
    }
    
    [recorder stop];
    
    //压缩文件延时
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(pushVoiceMessage) userInfo:nil repeats:NO];
}

- (void)playRecord:(UIButton *)sender {
    [player stop];
    NSMutableArray *singleMessage = [messageArrays objectAtIndex:(messageArrays.count - 1 - sender.tag)];
    NSString *recordFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:[singleMessage objectAtIndex:0]];
    
    NSLog(@"%@",recordFile);
    
    [player setSpeakMode:outputMode];
    [player playWithURL:[NSURL URLWithString:recordFile]];
}
//网络请求

//上传语音消息
- (void)pushVoiceMessage{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json",@"text/html", nil];
    
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    
    
    NSString *jsonStr= [NSString stringWithFormat:@"{\"shouhuan_id\":\"%@\",\"from_id\":\"%@\",\"from_type\":\"%@\"}",shouhuan_id,user_id,@"0"];
    
    NSLog(@"%@",jsonStr);
    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":jsonStr,
                                 };
    
    NSLog(@"%@",parameters);
    
    
    [manager POST:@"http://101.201.211.114:8080/APIPlatform/record" parameters:parameters constructingBodyWithBlock:^(id formData) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"test.amr"];
        
        NSData *tempData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedAlways error:nil];

        [formData appendPartWithFileData:tempData name:@"amr" fileName:@"test.amr" mimeType:@""];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self getVoicMessage];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}


- (void)getVoicMessage {
    messageArrays = [NSMutableArray new];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
    
    if (!shouhuan_id || !user_id) {
        return;
    }
    
    NSLog(@"shouhuan_id user_id : %@ %@",shouhuan_id,user_id);
    
    NSDate *senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *locationString=[dateformatter stringFromDate:senddate];

    
    NSDictionary *parameters = @{
                                 @"shouhuan_id":shouhuan_id,
                                 @"user_id":user_id,
                                 @"start_time":@"2014-09-26 00:00:00",
                                 @"end_time":[NSString stringWithFormat:@"%@ 23:59:59",locationString]
                                 };
    
    NSString *url=@"http://101.201.211.114:8080/APIPlatform/gethistoryrecord";
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        NSString *code = [dict objectForKey:@"code"];
        
        
        if ([code isEqualToString:@"100"]) {
            NSLog(@"getVoicMessage success");
            
            NSString *tempData = [dict objectForKey:@"data"];
            
            if (tempData.length <= 2) {
                
                NSLog(@"空值拦截");

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
                
                NSString *from_type = [jsonDict objectForKey:@"from_type"];
                
                NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:url];
                
                if (![NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedAlways error:nil]) {
                    NSLog(@" url : %@ ",url);
                    [self getVoiceDetailMessageByfilename:url];
                }
                NSMutableArray *singleMessage = [NSMutableArray arrayWithObjects:url,time,from_type, nil];
                
                if (singleMessage) {
                    [messageArrays addObject:singleMessage];
                }
            }
            
            [table reloadData];
            [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageArrays.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

            }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

- (void)getVoiceDetailMessageByfilename:(NSString *)fileName{
    NSLog(@"获取语音文件");
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%lu",(unsigned long)messageArrays.count);
    
    return messageArrays.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
    }
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    cellBgView = [[UIView alloc] initWithFrame:CGRectMake(6, 7, SCREEN_WIDTH - 32, 36)];
    NSMutableArray *singleMessage = [messageArrays objectAtIndex:(messageArrays.count - 1 - [indexPath row])];
    if ([[singleMessage objectAtIndex:2] intValue] == 0) {
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
        readStatus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"readStatus"]];
        readStatus.frame = CGRectMake(35, 8, 10, 20);
        [playButton addSubview:readStatus];
        [cellBgView addSubview:playButton];
        
        UILabel *sendTimelabel = [UILabel new];
        
        
        sendTimelabel.text = [singleMessage objectAtIndex:1];
        sendTimelabel.textAlignment = NSTextAlignmentCenter;
        sendTimelabel.font = [UIFont systemFontOfSize:10];
        sendTimelabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - 20, 10);
        
        [cell addSubview:sendTimelabel];
        [cell addSubview:cellBgView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([[singleMessage objectAtIndex:2] intValue] == 1) {
        UIImageView *portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 56, 3, 30, 30)];
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
        UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 209, 5, 150, 36) ];
        [playButton setTag:[indexPath row]];
        [playButton setBackgroundImage:[UIImage imageNamed:@"chatCellright"] forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
        [playButton setClipsToBounds:YES];
        [playButton setTag:[indexPath row]];
        //静态时图标
        readStatus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"readStatus"]];
        readStatus.frame = CGRectMake(35, 8, 10, 20);
        [playButton addSubview:readStatus];
        [cellBgView addSubview:playButton];
        
        UILabel *sendTimelabel = [UILabel new];
        
        
        sendTimelabel.text = [singleMessage objectAtIndex:1];
        sendTimelabel.textAlignment = NSTextAlignmentCenter;
        sendTimelabel.font = [UIFont systemFontOfSize:10];
        sendTimelabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - 20, 10);
        
        [cell addSubview:sendTimelabel];
        [cell addSubview:cellBgView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }

    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}
- (void)recorder:(PRNAmrRecorder *)aRecorder didRecordWithFile:(PRNAmrFileInfo *)fileInfo
{
    NSLog(@"==================================================================");
    NSLog(@"record with file : %@", fileInfo.fileUrl);
    NSLog(@"file size: %llu", fileInfo.fileSize);
    NSLog(@"file duration : %f", fileInfo.duration);
    NSLog(@"==================================================================");
}

@end
